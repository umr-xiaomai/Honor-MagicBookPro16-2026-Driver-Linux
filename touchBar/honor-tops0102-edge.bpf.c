// SPDX-License-Identifier: GPL-2.0-only
/*
 * HONOR MagicBook, Goodix TOPS0102 touchpad (I2C HID 27C6:0F9A).
 *
 * Feature
 *   Sliding along an edge of the touchpad is a HONOR gesture. The two edges
 *   are wired through completely different transports:
 *
 *     right edge  touchpad -> EC -> i8042 -> atkbd -> KEY_VOLUMEUP/DOWN
 *                 as discrete press/release pairs about 10 ms apart, roughly
 *                 22 per second. Nothing to fix, it works out of the box.
 *
 *     left edge   touchpad -> HID, and there it stops. The gesture is
 *                 reported on a vendor collection:
 *
 *                     Usage Page (Vendor 0xff00)
 *                     Usage (0x01)
 *                     Collection (Application)
 *                       Report ID (0x0e)
 *                       Report Count (8), Report Size (8)
 *                       Input (Data,Var,Abs)
 *                     End Collection
 *
 *                 carrying 0x0e 0x03 0x01 while sliding up and 0x0e 0x03 0x02
 *                 while sliding down, at about 10 reports per second.
 *                 drivers/hid/hid-input.c ignores HID_UP_MSVENDOR outright:
 *
 *                     case HID_UP_MSVENDOR:
 *                             goto ignore;
 *
 *                 so no input device is created and nothing reaches userspace.
 *
 * Why not just rewrite the descriptor
 *   Mapping the vendor collection onto a consumer usage with a descriptor
 *   fixup does not work. The firmware sends a stream of identical reports
 *   while the finger moves and no terminating report when it stops. For an
 *   array field hid_input_field() presses a usage when it appears and
 *   releases it when it disappears, and for a variable field the input core
 *   swallows repeated identical values. Either way the result is one key
 *   press that is never released. That is the same failure mode as the
 *   phantom KEY_MICMUTE this repository already fixes elsewhere.
 *
 * What this does instead
 *   The device event hook watches for the vendor report and injects a
 *   complete press and release pair on the touchpad's own consumer
 *   collection, which the firmware already declares wide open:
 *
 *       Usage Page (Consumer)
 *       Usage (Consumer Control)
 *       Collection (Application)
 *         Report ID (0x08)
 *         Usage Minimum (0x00), Usage Maximum (0x2ff)
 *         Report Size (16), Report Count (1)
 *         Input (Data,Array,Abs)
 *       End Collection
 *
 *   Usage 0x006f is Display Brightness Increment and 0x0070 is Display
 *   Brightness Decrement, both mapped by hid-input to KEY_BRIGHTNESSUP and
 *   KEY_BRIGHTNESSDOWN. One gesture report becomes one discrete key tap,
 *   which is exactly what the EC does for the right edge.
 *
 *   hid_bpf_try_input_report() is the non sleepable variant of the injection
 *   kfunc, documented as safe in IRQ context, so it can be called from the
 *   device event hook.
 *
 *   The vendor report is consumed rather than passed on: it is rewritten into
 *   the release half of the pair. Nothing in the kernel wants it, and leaving
 *   it in flight would deliver a stray event, see the comment in the hook.
 */

#include "vmlinux.h"
#include "hid_bpf.h"
#include "hid_bpf_helpers.h"
#include <bpf/bpf_tracing.h>

/*
 * The touchpad this was written against. install.sh passes -D for both from
 * the device profile, so a model with a different touchpad does not need a
 * copy of this file; the defaults keep it compilable on its own.
 */
#ifndef HID_VID
#define HID_VID		0x27c6
#endif
#ifndef HID_PID
#define HID_PID		0x0f9a
#endif

HID_BPF_CONFIG(
	HID_DEVICE(BUS_I2C, HID_GROUP_MULTITOUCH_WIN_8, HID_VID, HID_PID)
);

/* vendor collection carrying the edge gesture */
#define RID_VENDOR		0x0e
#define VENDOR_EVENT_EDGE	0x03
#define EDGE_UP			0x01
#define EDGE_DOWN		0x02

/* the touchpad's own consumer collection */
#define RID_CONSUMER		0x08
#define CONSUMER_REPORT_LEN	3

/* HID consumer usages, see the HID usage tables, Consumer page 0x0c */
#define USAGE_BRIGHTNESS_INC	0x006f
#define USAGE_BRIGHTNESS_DEC	0x0070

SEC(HID_BPF_DEVICE_EVENT)
int BPF_PROG(honor_tops0102_edge_event, struct hid_bpf_ctx *hctx)
{
	__u8 *data = hid_bpf_get_data(hctx, 0 /* offset */, 3 /* size */);
	__u8 press[CONSUMER_REPORT_LEN];
	__u16 usage;

	if (!data)
		return 0;

	/*
	 * Match on the report id first. A daemon scanning the whole buffer for
	 * the byte sequence also matches coordinates inside the 40 byte touch
	 * reports and fires at random; anchoring at offset 0 cannot. This test
	 * is also what stops the injected consumer reports below from being
	 * treated as gestures: they come back through this same hook.
	 */
	if (data[0] != RID_VENDOR || data[1] != VENDOR_EVENT_EDGE)
		return 0;

	if (data[2] == EDGE_UP)
		usage = USAGE_BRIGHTNESS_INC;
	else if (data[2] == EDGE_DOWN)
		usage = USAGE_BRIGHTNESS_DEC;
	else
		return 0;

	/*
	 * Order matters, and so does the fact that there is exactly one report
	 * buffer per device. dispatch_hid_bpf_device_event() points the context
	 * at hdev->bpf.device_data and refills it with memset plus memcpy on
	 * every dispatch, and an injected report runs through that same path.
	 * So the injection below overwrites the very buffer `data` points into.
	 *
	 * Hence: inject the press, which is delivered immediately, then turn
	 * what is left of this report into the release and shrink it to the
	 * consumer report length. Two reports, in the right order, and no
	 * leftover of the vendor report to be delivered as a stray event.
	 */
	press[0] = RID_CONSUMER;
	press[1] = usage & 0xff;
	press[2] = usage >> 8;
	hid_bpf_try_input_report(hctx, HID_INPUT_REPORT, press, sizeof(press));

	data[0] = RID_CONSUMER;
	data[1] = 0;
	data[2] = 0;

	return CONSUMER_REPORT_LEN;
}

HID_BPF_OPS(honor_tops0102_edge) = {
	.hid_device_event = (void *)honor_tops0102_edge_event,
};

char _license[] SEC("license") = "GPL";
