/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20240322 (64-bit version)
 * Copyright (c) 2000 - 2023 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of acpi-tables-from-boot7/ssdt27.dat
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00005C9C (23708)
 *     Revision         0x02
 *     Checksum         0xE5
 *     OEM ID           "HONOR"
 *     OEM Table ID     "I2C_DEVT"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200717 (538969879)
 */
DefinitionBlock ("", "SSDT", 2, "HONOR", "I2CDEVC", 0x00001000)
{
    External (_SB_.GGOV, MethodObj)    // 1 Arguments
    External (_SB_.GRXE, MethodObj)    // 2 Arguments
    External (_SB_.PC00, DeviceObj)
    External (_SB_.PC00.I2C0, DeviceObj)
    External (_SB_.PC00.I2C0.TPD0, DeviceObj)
    External (_SB_.PC00.I2C0.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C0.TPL1, DeviceObj)
    External (_SB_.PC00.I2C0.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C1, DeviceObj)
    External (_SB_.PC00.I2C1.PPDI, UnknownObj)
    External (_SB_.PC00.I2C1.TPD0, DeviceObj)
    External (_SB_.PC00.I2C1.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C1.TPDM, UnknownObj)
    External (_SB_.PC00.I2C1.TPL1, DeviceObj)
    External (_SB_.PC00.I2C1.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C2, DeviceObj)
    External (_SB_.PC00.I2C2.TPD0, DeviceObj)
    External (_SB_.PC00.I2C2.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C2.TPL1, DeviceObj)
    External (_SB_.PC00.I2C2.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C2.TPLM, UnknownObj)
    External (_SB_.PC00.I2C3, DeviceObj)
    External (_SB_.PC00.I2C3.TPD0, DeviceObj)
    External (_SB_.PC00.I2C3.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C3.TPL1, DeviceObj)
    External (_SB_.PC00.I2C3.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C4, DeviceObj)
    External (_SB_.PC00.I2C4.TPD0, DeviceObj)
    External (_SB_.PC00.I2C4.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C4.TPL1, DeviceObj)
    External (_SB_.PC00.I2C4.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C5, DeviceObj)
    External (_SB_.PC00.I2C5.TPD0, DeviceObj)
    External (_SB_.PC00.I2C5.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C5.TPL1, DeviceObj)
    External (_SB_.PC00.I2C5.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C6, DeviceObj)
    External (_SB_.PC00.I2C6.TPD0, DeviceObj)
    External (_SB_.PC00.I2C6.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C6.TPL1, DeviceObj)
    External (_SB_.PC00.I2C6.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C7, DeviceObj)
    External (_SB_.PC00.I2C7.TPD0, DeviceObj)
    External (_SB_.PC00.I2C7.TPD0._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC00.I2C7.TPL1, DeviceObj)
    External (_SB_.PC00.I2C7.TPL1._STA, MethodObj)    // 0 Arguments
    External (_SB_.PC02, DeviceObj)
    External (_SB_.PC02.I2C0, DeviceObj)
    External (_SB_.PC02.I2C0.TPD0, DeviceObj)
    External (_SB_.PC02.I2C0.TPL1, DeviceObj)
    External (_SB_.PC02.I2C1, DeviceObj)
    External (_SB_.PC02.I2C1.TPD0, DeviceObj)
    External (_SB_.PC02.I2C1.TPL1, DeviceObj)
    External (_SB_.PC02.I2C2, DeviceObj)
    External (_SB_.PC02.I2C2.TPD0, DeviceObj)
    External (_SB_.PC02.I2C2.TPL1, DeviceObj)
    External (_SB_.PC02.I2C3, DeviceObj)
    External (_SB_.PC02.I2C3.TPD0, DeviceObj)
    External (_SB_.PC02.I2C3.TPL1, DeviceObj)
    External (_SB_.PC02.I2C4, DeviceObj)
    External (_SB_.PC02.I2C4.TPD0, DeviceObj)
    External (_SB_.PC02.I2C4.TPL1, DeviceObj)
    External (_SB_.PC02.I2C5, DeviceObj)
    External (_SB_.PC02.I2C5.TPD0, DeviceObj)
    External (_SB_.PC02.I2C5.TPL1, DeviceObj)
    External (_SB_.SGII, MethodObj)    // 2 Arguments
    External (_SB_.SGOV, MethodObj)    // 2 Arguments
    External (_SB_.SGRA, MethodObj)    // 2 Arguments
    External (_SB_.SHPO, MethodObj)    // 2 Arguments
    External (ADBG, MethodObj)    // 1 Arguments
    External (G_IN, MethodObj)    // 6 Arguments
    External (GNUM, MethodObj)    // 1 Arguments
    External (IC0D, FieldUnitObj)
    External (IC1D, FieldUnitObj)
    External (INUM, MethodObj)    // 1 Arguments
    External (PCHA, UnknownObj)
    External (SDS0, UnknownObj)
    External (SDS1, UnknownObj)
    External (SDS2, UnknownObj)
    External (SDS3, UnknownObj)
    External (SDS4, UnknownObj)
    External (SDS5, UnknownObj)
    External (TPDM, UnknownObj)
    External (TPDT, UnknownObj)
    External (TPLM, UnknownObj)
    External (TPLT, UnknownObj)
    External (VRRD, FieldUnitObj)

    Name (TPTD, Package (0x08)
    {
        0x07, 
        Zero, 
        0x38, 
        One, 
        0x01, 
        0x00, 
        0x01, 
        0x00
    })
    Name (TDPH, Package (0x02)
    {
        One, 
        0xFFFF
    })
    Name (TPDI, Package (0x03)
    {
        0x001A0894, 
        0x001A090B, 
        0x001A0412
    })
    Scope (\_SB.PC00)
    {
        Name (HIDG, ToUUID ("3cdff6f7-4267-4555-ad05-b30a3d8938de") /* HID I2C Device */)
        Name (TP7G, ToUUID ("ef87eb82-f951-46da-84ec-14871ac6f84b") /* Unknown UUID */)
        Method (HOID, 5, Serialized)
        {
            If ((Arg0 == HIDG))
            {
                If ((Arg2 == Zero))
                {
                    If ((Arg1 == One))
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                }

                If ((Arg2 == One))
                {
                    Return (Arg4)
                }
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        Method (TP7D, 6, Serialized)
        {
            If ((Arg0 == TP7G))
            {
                If ((Arg2 == Zero))
                {
                    If ((Arg1 == One))
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                }

                If ((Arg2 == One))
                {
                    Return (ConcatenateResTemplate (Arg4, Arg5))
                }
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        Method (I2CM, 3, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (Zero)
                {
                    Name (IIC0, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C0",
                            0x00, ResourceConsumer, _Y00, Exclusive,
                            )
                    })
                    CreateWordField (IIC0, \_SB.PC00.I2CM._Y00._ADR, DAD0)  // _ADR: Address
                    CreateDWordField (IIC0, \_SB.PC00.I2CM._Y00._SPE, DSP0)  // _SPE: Speed
                    DAD0 = Arg1
                    DSP0 = Arg2
                    Return (IIC0) /* \_SB_.PC00.I2CM.IIC0 */
                }
                Case (One)
                {
                    Name (IIC1, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C1",
                            0x00, ResourceConsumer, _Y01, Exclusive,
                            )
                    })
                    CreateWordField (IIC1, \_SB.PC00.I2CM._Y01._ADR, DAD1)  // _ADR: Address
                    CreateDWordField (IIC1, \_SB.PC00.I2CM._Y01._SPE, DSP1)  // _SPE: Speed
                    DAD1 = Arg1
                    DSP1 = Arg2
                    Return (IIC1) /* \_SB_.PC00.I2CM.IIC1 */
                }
                Case (0x02)
                {
                    Name (IIC2, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C2",
                            0x00, ResourceConsumer, _Y02, Exclusive,
                            )
                    })
                    CreateWordField (IIC2, \_SB.PC00.I2CM._Y02._ADR, DAD2)  // _ADR: Address
                    CreateDWordField (IIC2, \_SB.PC00.I2CM._Y02._SPE, DSP2)  // _SPE: Speed
                    DAD2 = Arg1
                    DSP2 = Arg2
                    Return (IIC2) /* \_SB_.PC00.I2CM.IIC2 */
                }
                Case (0x03)
                {
                    Name (IIC3, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C3",
                            0x00, ResourceConsumer, _Y03, Exclusive,
                            )
                    })
                    CreateWordField (IIC3, \_SB.PC00.I2CM._Y03._ADR, DAD3)  // _ADR: Address
                    CreateDWordField (IIC3, \_SB.PC00.I2CM._Y03._SPE, DSP3)  // _SPE: Speed
                    DAD3 = Arg1
                    DSP3 = Arg2
                    Return (IIC3) /* \_SB_.PC00.I2CM.IIC3 */
                }
                Case (0x04)
                {
                    Name (IIC4, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C4",
                            0x00, ResourceConsumer, _Y04, Exclusive,
                            )
                    })
                    CreateWordField (IIC4, \_SB.PC00.I2CM._Y04._ADR, DAD4)  // _ADR: Address
                    CreateDWordField (IIC4, \_SB.PC00.I2CM._Y04._SPE, DSP4)  // _SPE: Speed
                    DAD4 = Arg1
                    DSP4 = Arg2
                    Return (IIC4) /* \_SB_.PC00.I2CM.IIC4 */
                }
                Case (0x05)
                {
                    Name (IIC5, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C5",
                            0x00, ResourceConsumer, _Y05, Exclusive,
                            )
                    })
                    CreateWordField (IIC5, \_SB.PC00.I2CM._Y05._ADR, DAD5)  // _ADR: Address
                    CreateDWordField (IIC5, \_SB.PC00.I2CM._Y05._SPE, DSP5)  // _SPE: Speed
                    DAD5 = Arg1
                    DSP5 = Arg2
                    Return (IIC5) /* \_SB_.PC00.I2CM.IIC5 */
                }
                Default
                {
                    Return (Zero)
                }

            }
        }

        Method (UCMM, 1, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (Zero)
                {
                    Name (UCM0, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C0",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x003F, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C0",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0020, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C0",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0027, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C0",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                    })
                    Return (UCM0) /* \_SB_.PC00.UCMM.UCM0 */
                }
                Case (One)
                {
                    Name (UCM1, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C1",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x003F, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C1",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0020, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C1",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0027, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C1",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                    })
                    Return (UCM1) /* \_SB_.PC00.UCMM.UCM1 */
                }
                Case (0x02)
                {
                    Name (UCM2, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C2",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x003F, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C2",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0020, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C2",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0027, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C2",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                    })
                    Return (UCM2) /* \_SB_.PC00.UCMM.UCM2 */
                }
                Case (0x03)
                {
                    Name (UCM3, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C3",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x003F, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C3",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0020, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C3",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0027, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C3",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                    })
                    Return (UCM3) /* \_SB_.PC00.UCMM.UCM3 */
                }
                Case (0x04)
                {
                    Name (UCM4, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C4",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x003F, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C4",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0020, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C4",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0027, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C4",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                    })
                    Return (UCM4) /* \_SB_.PC00.UCMM.UCM4 */
                }
                Case (0x05)
                {
                    Name (UCM5, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C5",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x003F, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C5",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0020, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C5",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        I2cSerialBusV2 (0x0027, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PC00.I2C5",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                    })
                    Return (UCM5) /* \_SB_.PC00.UCMM.UCM5 */
                }
                Default
                {
                    Return (Zero)
                }

            }
        }
    }

    Scope (\_SB.PC00.I2C0)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        Name (I2CI, Zero)
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            I2CN = SDS0 /* External reference */
            I2CX = Zero
        }

        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("f87a6d23-2884-4fe4-a55f-633d9e339ce1") /* Unknown UUID */, 
            Package (0x04)
            {
                Package (0x02)
                {
                    "idle-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "SS-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FM-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FMP-active-latency-tolerance", 
                    0xFFFF
                }
            }
        })
    }

    Scope (\_SB.PC00.I2C1)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        Name (I2CI, One)
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            I2CN = SDS1 /* External reference */
            I2CX = One
        }

        Device (TPD0)
        {
            Name (HID2, Zero)
            Name (SBFB, ResourceTemplate ()
            {
                I2cSerialBusV2 (0x005D, ControllerInitiated, 0x00061A80,
                    AddressingMode7Bit, "\\_SB.PC00.I2C1",
                    0x00, ResourceConsumer, _Y06, Exclusive,
                    )
            })
            Name (SBFI, ResourceTemplate ()
            {
                Interrupt (ResourceConsumer, Level, ActiveLow, ExclusiveAndWake, ,, _Y07)
                {
                    0x00000000,
                }
            })
            CreateWordField (SBFB, \_SB.PC00.I2C1.TPD0._Y06._ADR, BADR)  // _ADR: Address
            CreateDWordField (SBFB, \_SB.PC00.I2C1.TPD0._Y06._SPE, SPED)  // _SPE: Speed
            CreateDWordField (SBFI, \_SB.PC00.I2C1.TPD0._Y07._INT, INT2)  // _INT: Interrupts
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                INT2 = INUM (DerefOf (TPDI [Zero]))
                If ((DerefOf (TPTD [0x05]) == Zero))
                {
                    SHPO (DerefOf (TPDI [Zero]), One)
                }

                SGRA (DerefOf (TPDI [Zero]), TPDM)
                If ((DerefOf (TPTD [0x05]) == One))
                {
                    SGII (DerefOf (TPDI [Zero]), Zero)
                    GRXE (DerefOf (TPDI [Zero]), Zero)
                }

                If ((TPDT == One))
                {
                    _HID = "TOPS0102"
                    HID2 = One
                    BADR = 0x5D
                }
            }

            Name (_HID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _HID: Hardware ID
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == HIDG))
                {
                    Return (HOID (Arg0, Arg1, Arg2, Arg3, HID2))
                }

                If ((Arg0 == TP7G))
                {
                    Return (TP7D (Arg0, Arg1, Arg2, Arg3, SBFB, G_IN (DerefOf (TPDI [Zero]
                        ), Zero, One, 0x02, Zero, Zero)))
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TPDT == One))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                If ((DerefOf (TPTD [0x05]) == Zero))
                {
                    Return (ConcatenateResTemplate (I2CM (I2CX, BADR, SPED), G_IN (DerefOf (TPDI [Zero]), 
                        Zero, One, 0x02, Zero, Zero)))
                }

                Return (ConcatenateResTemplate (I2CM (I2CX, BADR, SPED), SBFI))
            }
        }

        Device (NFC0)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_HID, "NTAG0001")  // _HID: Hardware ID
            Name (_CID, "NTAG0001")  // _CID: Compatible ID
            Name (SBFU, ResourceTemplate ()
            {
                I2cSerialBusV2 (0x0057, ControllerInitiated, 0x00061A80,
                    AddressingMode7Bit, "\\_SB.PC00.I2C1",
                    0x00, ResourceConsumer, , Exclusive,
                    )
            })
            Name (SBGF, ResourceTemplate ()
            {
                GpioInt (Edge, ActiveHigh, Exclusive, PullDefault, 0x0000,
                    "\\_SB.GPI3", 0x00, ResourceConsumer, ,
                    )
                    {   // Pin list
                        0x0000
                    }
            })
            CreateWordField (SBGF, 0x17, INT1)
            // [FIX] This used to be a module-level "INT1 = GNUM (0x001A088A)".
            // At table-load time GNUM/GINF index the GPCS package before the
            // namespace is ready -> AE_AML_INTERNAL -> the whole table is rolled
            // back. Moved into _CRS below (runtime), where the namespace is ready
            // and GNUM works. TPD0 is left entirely untouched (OEM dynamic calc).
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TPDT == One))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                INT1 = GNUM (0x001A088A)   // [FIX] runtime computation of NFC interrupt; no longer at table load
                Return (ConcatenateResTemplate (SBFU, SBGF))
            }
        }

        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("f87a6d23-2884-4fe4-a55f-633d9e339ce1") /* Unknown UUID */, 
            Package (0x04)
            {
                Package (0x02)
                {
                    "idle-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "SS-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FM-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FMP-active-latency-tolerance", 
                    0xFFFF
                }
            }
        })
    }

    Scope (\_SB.PC00.I2C2)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        Name (I2CI, 0x02)
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            I2CN = SDS2 /* External reference */
            I2CX = 0x02
        }

        Device (TPL1)
        {
            Name (HID2, Zero)
            Name (SBFB, ResourceTemplate ()
            {
                I2cSerialBusV2 (0x0038, ControllerInitiated, 0x00061A80,
                    AddressingMode7Bit, "NULL",
                    0x00, ResourceConsumer, _Y08, Exclusive,
                    )
            })
            Name (SBFI, ResourceTemplate ()
            {
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, _Y09)
                {
                    0x00000000,
                }
            })
            CreateWordField (SBFB, \_SB.PC00.I2C2.TPL1._Y08._ADR, BADR)  // _ADR: Address
            CreateDWordField (SBFB, \_SB.PC00.I2C2.TPL1._Y08._SPE, SPED)  // _SPE: Speed
            CreateDWordField (SBFI, \_SB.PC00.I2C2.TPL1._Y09._INT, INT2)  // _INT: Interrupts
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                ADBG ("Touch Panel INI is getting called")
                INT2 = INUM (DerefOf (TPDI [One]))
                ADBG (Concatenate ("TPLM PchI2cTouchPanelIrqMode", ToHexString (DerefOf (TPTD [One]))))
                If ((DerefOf (TPTD [One]) == Zero))
                {
                    SHPO (DerefOf (TPDI [One]), One)
                }

                GRXE (DerefOf (TPDI [One]), Zero)
                If ((TPLM == One))
                {
                    GRXE (DerefOf (TPDI [One]), One)
                }

                SGRA (DerefOf (TPDI [One]), TPLM)
                If ((DerefOf (TPTD [Zero]) == 0x07))
                {
                    ADBG (Concatenate ("TPLT PchI2cTouchPanelType", ToHexString (DerefOf (TPTD [Zero]))))
                    _HID = "FTSC1000"
                    HID2 = DerefOf (TDPH [Zero])
                    BADR = DerefOf (TPTD [0x02])
                    ADBG (Concatenate ("TPLS PchI2cTouchPanelSpeed", ToHexString (DerefOf (TPTD [0x03]))))
                    If ((DerefOf (TPTD [0x03]) == Zero))
                    {
                        SPED = 0x000186A0
                    }

                    If ((DerefOf (TPTD [0x03]) == One))
                    {
                        SPED = 0x00061A80
                    }

                    If ((DerefOf (TPTD [0x03]) == 0x02))
                    {
                        SPED = 0x000F4240
                    }

                    Return (Zero)
                }
            }

            Name (_HID, "XXXX0000")  // _HID: Hardware ID
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Method (_UID, 0, NotSerialized)  // _UID: Unique ID
            {
                Return (I2CI) /* \_SB_.PC00.I2C2.I2CI */
            }

            Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == HIDG))
                {
                    Return (HOID (Arg0, Arg1, Arg2, Arg3, HID2))
                }

                If ((Arg0 == TP7G))
                {
                    Return (TP7D (Arg0, Arg1, Arg2, Arg3, SBFB, G_IN (DerefOf (TPDI [One]
                        ), Zero, One, Zero, Zero, Zero)))
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TPLT == One))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                If ((DerefOf (TPTD [One]) == Zero))
                {
                    Return (ConcatenateResTemplate (I2CM (I2CX, BADR, SPED), G_IN (DerefOf (TPDI [One]), 
                        Zero, One, Zero, Zero, Zero)))
                }

                ADBG (Concatenate ("TPLM PchI2cTouchPanelIrqMode", ToHexString (DerefOf (TPTD [One]))))
                Return (ConcatenateResTemplate (I2CM (I2CX, BADR, SPED), SBFI))
            }
        }

        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("f87a6d23-2884-4fe4-a55f-633d9e339ce1") /* Unknown UUID */, 
            Package (0x04)
            {
                Package (0x02)
                {
                    "idle-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "SS-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FM-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FMP-active-latency-tolerance", 
                    0xFFFF
                }
            }
        })
    }

    Scope (\_SB.PC00.I2C3)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        Name (I2CI, 0x03)
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            I2CN = SDS3 /* External reference */
            I2CX = 0x03
        }

        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("f87a6d23-2884-4fe4-a55f-633d9e339ce1") /* Unknown UUID */, 
            Package (0x04)
            {
                Package (0x02)
                {
                    "idle-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "SS-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FM-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FMP-active-latency-tolerance", 
                    0xFFFF
                }
            }
        })
    }

    Scope (\_SB.PC00.I2C4)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        Name (I2CI, 0x04)
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            I2CN = SDS4 /* External reference */
            I2CX = 0x04
        }

        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("f87a6d23-2884-4fe4-a55f-633d9e339ce1") /* Unknown UUID */, 
            Package (0x04)
            {
                Package (0x02)
                {
                    "idle-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "SS-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FM-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FMP-active-latency-tolerance", 
                    0xFFFF
                }
            }
        })
    }

    Scope (\_SB.PC00.I2C5)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        Name (I2CI, 0x05)
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            I2CN = SDS5 /* External reference */
            I2CX = 0x05
        }

        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("f87a6d23-2884-4fe4-a55f-633d9e339ce1") /* Unknown UUID */, 
            Package (0x04)
            {
                Package (0x02)
                {
                    "idle-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "SS-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FM-active-latency-tolerance", 
                    0xFFFF
                }, 

                Package (0x02)
                {
                    "FMP-active-latency-tolerance", 
                    0xFFFF
                }
            }
        })
    }

    Name (I2BU, Buffer (0xB8)
    {
        /* 0000 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0030 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0038 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0040 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0048 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0050 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0058 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0068 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0070 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0080 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0088 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 0098 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 00A8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
        /* 00B0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
    })
    Name (I2EN, Zero)
    CreateByteField (I2BU, Zero, KN00)
    ADBG (Concatenate ("KN00", Concatenate ("0x", ToHexString (KN00))))
    CreateByteField (I2BU, One, EE00)
    ADBG (Concatenate ("EE00", Concatenate ("0x", ToHexString (EE00))))
    CreateDWordField (I2BU, 0x02, GG00)
    ADBG (Concatenate ("GG00", Concatenate ("0x", ToHexString (GG00))))
    CreateByteField (I2BU, 0x06, GP00)
    ADBG (Concatenate ("GP00", Concatenate ("0x", ToHexString (GP00))))
    CreateDWordField (I2BU, 0x0C, HG00)
    ADBG (Concatenate ("HG00", Concatenate ("0x", ToHexString (HG00))))
    CreateByteField (I2BU, 0x10, HP00)
    ADBG (Concatenate ("HP00", Concatenate ("0x", ToHexString (HP00))))
    CreateDWordField (I2BU, 0x11, IG00)
    ADBG (Concatenate ("IG00", Concatenate ("0x", ToHexString (IG00))))
    CreateByteField (I2BU, 0x15, IP00)
    ADBG (Concatenate ("IP00", Concatenate ("0x", ToHexString (IP00))))
    CreateDWordField (I2BU, 0x07, JG00)
    ADBG (Concatenate ("JG00", Concatenate ("0x", ToHexString (JG00))))
    CreateByteField (I2BU, 0x0B, JP00)
    ADBG (Concatenate ("JP00", Concatenate ("0x", ToHexString (JP00))))
    If (KN00)
    {
        If (CondRefOf (\_SB.PC00.I2C0))
        {
            Scope (\_SB.PC00.I2C0)
            {
                I2EN = KN00 /* \KN00 */
                Name (EPDO, Zero)
                EPDO = EE00 /* \EE00 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG00 /* \GG00 */
                PIRT [One] = GP00 /* \GP00 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG00 /* \HG00 */
                TPWR [One] = HP00 /* \HP00 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG00 /* \IG00 */
                TRST [One] = IP00 /* \IP00 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG00 /* \JG00 */
                TIRT [One] = JP00 /* \JP00 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000000")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000000")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000000")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000000")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000000")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000000")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C0.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C0.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C0.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C0.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C0.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C0.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C0.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C0.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x16, KN01)
    ADBG (Concatenate ("KN01", Concatenate ("0x", ToHexString (KN01))))
    CreateByteField (I2BU, 0x17, EE01)
    ADBG (Concatenate ("EE01", Concatenate ("0x", ToHexString (EE01))))
    CreateDWordField (I2BU, 0x18, GG01)
    ADBG (Concatenate ("GG01", Concatenate ("0x", ToHexString (GG01))))
    CreateByteField (I2BU, 0x1C, GP01)
    ADBG (Concatenate ("GP01", Concatenate ("0x", ToHexString (GP01))))
    CreateDWordField (I2BU, 0x22, HG01)
    ADBG (Concatenate ("HG01", Concatenate ("0x", ToHexString (HG01))))
    CreateByteField (I2BU, 0x26, HP01)
    ADBG (Concatenate ("HP01", Concatenate ("0x", ToHexString (HP01))))
    CreateDWordField (I2BU, 0x27, IG01)
    ADBG (Concatenate ("IG01", Concatenate ("0x", ToHexString (IG01))))
    CreateByteField (I2BU, 0x2B, IP01)
    ADBG (Concatenate ("IP01", Concatenate ("0x", ToHexString (IP01))))
    CreateDWordField (I2BU, 0x1D, JG01)
    ADBG (Concatenate ("JG01", Concatenate ("0x", ToHexString (JG01))))
    CreateByteField (I2BU, 0x21, JP01)
    ADBG (Concatenate ("JP01", Concatenate ("0x", ToHexString (JP01))))
    If (KN01)
    {
        If (CondRefOf (\_SB.PC00.I2C1))
        {
            Scope (\_SB.PC00.I2C1)
            {
                I2EN = KN01 /* \KN01 */
                Name (EPDO, Zero)
                EPDO = EE01 /* \EE01 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG01 /* \GG01 */
                PIRT [One] = GP01 /* \GP01 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG01 /* \HG01 */
                TPWR [One] = HP01 /* \HP01 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG01 /* \IG01 */
                TRST [One] = IP01 /* \IP01 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG01 /* \JG01 */
                TIRT [One] = JP01 /* \JP01 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000001")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000001")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000001")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000001")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000001")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000001")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C1.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C1.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C1.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C1.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C1.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C1.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C1.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C1.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x2C, KN02)
    ADBG (Concatenate ("KN02", Concatenate ("0x", ToHexString (KN02))))
    CreateByteField (I2BU, 0x2D, EE02)
    ADBG (Concatenate ("EE02", Concatenate ("0x", ToHexString (EE02))))
    CreateDWordField (I2BU, 0x2E, GG02)
    ADBG (Concatenate ("GG02", Concatenate ("0x", ToHexString (GG02))))
    CreateByteField (I2BU, 0x32, GP02)
    ADBG (Concatenate ("GP02", Concatenate ("0x", ToHexString (GP02))))
    CreateDWordField (I2BU, 0x38, HG02)
    ADBG (Concatenate ("HG02", Concatenate ("0x", ToHexString (HG02))))
    CreateByteField (I2BU, 0x3C, HP02)
    ADBG (Concatenate ("HP02", Concatenate ("0x", ToHexString (HP02))))
    CreateDWordField (I2BU, 0x3D, IG02)
    ADBG (Concatenate ("IG02", Concatenate ("0x", ToHexString (IG02))))
    CreateByteField (I2BU, 0x41, IP02)
    ADBG (Concatenate ("IP02", Concatenate ("0x", ToHexString (IP02))))
    CreateDWordField (I2BU, 0x33, JG02)
    ADBG (Concatenate ("JG02", Concatenate ("0x", ToHexString (JG02))))
    CreateByteField (I2BU, 0x37, JP02)
    ADBG (Concatenate ("JP02", Concatenate ("0x", ToHexString (JP02))))
    If (KN02)
    {
        If (CondRefOf (\_SB.PC00.I2C2))
        {
            Scope (\_SB.PC00.I2C2)
            {
                I2EN = KN02 /* \KN02 */
                Name (EPDO, Zero)
                EPDO = EE02 /* \EE02 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG02 /* \GG02 */
                PIRT [One] = GP02 /* \GP02 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG02 /* \HG02 */
                TPWR [One] = HP02 /* \HP02 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG02 /* \IG02 */
                TRST [One] = IP02 /* \IP02 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG02 /* \JG02 */
                TIRT [One] = JP02 /* \JP02 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000002")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000002")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000002")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000002")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000002")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000002")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C2.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C2.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C2.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C2.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C2.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C2.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C2.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C2.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x42, KN03)
    ADBG (Concatenate ("KN03", Concatenate ("0x", ToHexString (KN03))))
    CreateByteField (I2BU, 0x43, EE03)
    ADBG (Concatenate ("EE03", Concatenate ("0x", ToHexString (EE03))))
    CreateDWordField (I2BU, 0x44, GG03)
    ADBG (Concatenate ("GG03", Concatenate ("0x", ToHexString (GG03))))
    CreateByteField (I2BU, 0x48, GP03)
    ADBG (Concatenate ("GP03", Concatenate ("0x", ToHexString (GP03))))
    CreateDWordField (I2BU, 0x4E, HG03)
    ADBG (Concatenate ("HG03", Concatenate ("0x", ToHexString (HG03))))
    CreateByteField (I2BU, 0x52, HP03)
    ADBG (Concatenate ("HP03", Concatenate ("0x", ToHexString (HP03))))
    CreateDWordField (I2BU, 0x53, IG03)
    ADBG (Concatenate ("IG03", Concatenate ("0x", ToHexString (IG03))))
    CreateByteField (I2BU, 0x57, IP03)
    ADBG (Concatenate ("IP03", Concatenate ("0x", ToHexString (IP03))))
    CreateDWordField (I2BU, 0x49, JG03)
    ADBG (Concatenate ("JG03", Concatenate ("0x", ToHexString (JG03))))
    CreateByteField (I2BU, 0x4D, JP03)
    ADBG (Concatenate ("JP03", Concatenate ("0x", ToHexString (JP03))))
    If (KN03)
    {
        If (CondRefOf (\_SB.PC00.I2C3))
        {
            Scope (\_SB.PC00.I2C3)
            {
                I2EN = KN03 /* \KN03 */
                Name (EPDO, Zero)
                EPDO = EE03 /* \EE03 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG03 /* \GG03 */
                PIRT [One] = GP03 /* \GP03 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG03 /* \HG03 */
                TPWR [One] = HP03 /* \HP03 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG03 /* \IG03 */
                TRST [One] = IP03 /* \IP03 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG03 /* \JG03 */
                TIRT [One] = JP03 /* \JP03 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000003")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000003")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000003")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000003")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000003")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000003")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C3.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C3.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C3.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C3.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C3.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C3.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C3.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C3.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x58, KN04)
    ADBG (Concatenate ("KN04", Concatenate ("0x", ToHexString (KN04))))
    CreateByteField (I2BU, 0x59, EE04)
    ADBG (Concatenate ("EE04", Concatenate ("0x", ToHexString (EE04))))
    CreateDWordField (I2BU, 0x5A, GG04)
    ADBG (Concatenate ("GG04", Concatenate ("0x", ToHexString (GG04))))
    CreateByteField (I2BU, 0x5E, GP04)
    ADBG (Concatenate ("GP04", Concatenate ("0x", ToHexString (GP04))))
    CreateDWordField (I2BU, 0x64, HG04)
    ADBG (Concatenate ("HG04", Concatenate ("0x", ToHexString (HG04))))
    CreateByteField (I2BU, 0x68, HP04)
    ADBG (Concatenate ("HP04", Concatenate ("0x", ToHexString (HP04))))
    CreateDWordField (I2BU, 0x69, IG04)
    ADBG (Concatenate ("IG04", Concatenate ("0x", ToHexString (IG04))))
    CreateByteField (I2BU, 0x6D, IP04)
    ADBG (Concatenate ("IP04", Concatenate ("0x", ToHexString (IP04))))
    CreateDWordField (I2BU, 0x5F, JG04)
    ADBG (Concatenate ("JG04", Concatenate ("0x", ToHexString (JG04))))
    CreateByteField (I2BU, 0x63, JP04)
    ADBG (Concatenate ("JP04", Concatenate ("0x", ToHexString (JP04))))
    If (KN04)
    {
        If (CondRefOf (\_SB.PC00.I2C4))
        {
            Scope (\_SB.PC00.I2C4)
            {
                I2EN = KN04 /* \KN04 */
                Name (EPDO, Zero)
                EPDO = EE04 /* \EE04 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG04 /* \GG04 */
                PIRT [One] = GP04 /* \GP04 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG04 /* \HG04 */
                TPWR [One] = HP04 /* \HP04 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG04 /* \IG04 */
                TRST [One] = IP04 /* \IP04 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG04 /* \JG04 */
                TIRT [One] = JP04 /* \JP04 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000004")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000004")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000004")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000004")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000004")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000004")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C4.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C4.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C4.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C4.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C4.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C4.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C4.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C4.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x6E, KN05)
    ADBG (Concatenate ("KN05", Concatenate ("0x", ToHexString (KN05))))
    CreateByteField (I2BU, 0x6F, EE05)
    ADBG (Concatenate ("EE05", Concatenate ("0x", ToHexString (EE05))))
    CreateDWordField (I2BU, 0x70, GG05)
    ADBG (Concatenate ("GG05", Concatenate ("0x", ToHexString (GG05))))
    CreateByteField (I2BU, 0x74, GP05)
    ADBG (Concatenate ("GP05", Concatenate ("0x", ToHexString (GP05))))
    CreateDWordField (I2BU, 0x7A, HG05)
    ADBG (Concatenate ("HG05", Concatenate ("0x", ToHexString (HG05))))
    CreateByteField (I2BU, 0x7E, HP05)
    ADBG (Concatenate ("HP05", Concatenate ("0x", ToHexString (HP05))))
    CreateDWordField (I2BU, 0x7F, IG05)
    ADBG (Concatenate ("IG05", Concatenate ("0x", ToHexString (IG05))))
    CreateByteField (I2BU, 0x83, IP05)
    ADBG (Concatenate ("IP05", Concatenate ("0x", ToHexString (IP05))))
    CreateDWordField (I2BU, 0x75, JG05)
    ADBG (Concatenate ("JG05", Concatenate ("0x", ToHexString (JG05))))
    CreateByteField (I2BU, 0x79, JP05)
    ADBG (Concatenate ("JP05", Concatenate ("0x", ToHexString (JP05))))
    If (KN05)
    {
        If (CondRefOf (\_SB.PC00.I2C5))
        {
            Scope (\_SB.PC00.I2C5)
            {
                I2EN = KN05 /* \KN05 */
                Name (EPDO, Zero)
                EPDO = EE05 /* \EE05 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG05 /* \GG05 */
                PIRT [One] = GP05 /* \GP05 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG05 /* \HG05 */
                TPWR [One] = HP05 /* \HP05 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG05 /* \IG05 */
                TRST [One] = IP05 /* \IP05 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG05 /* \JG05 */
                TIRT [One] = JP05 /* \JP05 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000005")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000005")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000005")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000005")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000005")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000005")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C5.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C5.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C5.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C5.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C5.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C5.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C5.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C5.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x84, KN06)
    ADBG (Concatenate ("KN06", Concatenate ("0x", ToHexString (KN06))))
    CreateByteField (I2BU, 0x85, EE06)
    ADBG (Concatenate ("EE06", Concatenate ("0x", ToHexString (EE06))))
    CreateDWordField (I2BU, 0x86, GG06)
    ADBG (Concatenate ("GG06", Concatenate ("0x", ToHexString (GG06))))
    CreateByteField (I2BU, 0x8A, GP06)
    ADBG (Concatenate ("GP06", Concatenate ("0x", ToHexString (GP06))))
    CreateDWordField (I2BU, 0x90, HG06)
    ADBG (Concatenate ("HG06", Concatenate ("0x", ToHexString (HG06))))
    CreateByteField (I2BU, 0x94, HP06)
    ADBG (Concatenate ("HP06", Concatenate ("0x", ToHexString (HP06))))
    CreateDWordField (I2BU, 0x95, IG06)
    ADBG (Concatenate ("IG06", Concatenate ("0x", ToHexString (IG06))))
    CreateByteField (I2BU, 0x99, IP06)
    ADBG (Concatenate ("IP06", Concatenate ("0x", ToHexString (IP06))))
    CreateDWordField (I2BU, 0x8B, JG06)
    ADBG (Concatenate ("JG06", Concatenate ("0x", ToHexString (JG06))))
    CreateByteField (I2BU, 0x8F, JP06)
    ADBG (Concatenate ("JP06", Concatenate ("0x", ToHexString (JP06))))
    If (KN06)
    {
        If (CondRefOf (\_SB.PC00.I2C6))
        {
            Scope (\_SB.PC00.I2C6)
            {
                I2EN = KN06 /* \KN06 */
                Name (EPDO, Zero)
                EPDO = EE06 /* \EE06 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG06 /* \GG06 */
                PIRT [One] = GP06 /* \GP06 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG06 /* \HG06 */
                TPWR [One] = HP06 /* \HP06 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG06 /* \IG06 */
                TRST [One] = IP06 /* \IP06 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG06 /* \JG06 */
                TIRT [One] = JP06 /* \JP06 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000006")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000006")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000006")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000006")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000006")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000006")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C6.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C6.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C6.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C6.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C6.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C6.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C6.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C6.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CreateByteField (I2BU, 0x9A, KN07)
    ADBG (Concatenate ("KN07", Concatenate ("0x", ToHexString (KN07))))
    CreateByteField (I2BU, 0x9B, EE07)
    ADBG (Concatenate ("EE07", Concatenate ("0x", ToHexString (EE07))))
    CreateDWordField (I2BU, 0x9C, GG07)
    ADBG (Concatenate ("GG07", Concatenate ("0x", ToHexString (GG07))))
    CreateByteField (I2BU, 0xA0, GP07)
    ADBG (Concatenate ("GP07", Concatenate ("0x", ToHexString (GP07))))
    CreateDWordField (I2BU, 0xA6, HG07)
    ADBG (Concatenate ("HG07", Concatenate ("0x", ToHexString (HG07))))
    CreateByteField (I2BU, 0xAA, HP07)
    ADBG (Concatenate ("HP07", Concatenate ("0x", ToHexString (HP07))))
    CreateDWordField (I2BU, 0xAB, IG07)
    ADBG (Concatenate ("IG07", Concatenate ("0x", ToHexString (IG07))))
    CreateByteField (I2BU, 0xAF, IP07)
    ADBG (Concatenate ("IP07", Concatenate ("0x", ToHexString (IP07))))
    CreateDWordField (I2BU, 0xA1, JG07)
    ADBG (Concatenate ("JG07", Concatenate ("0x", ToHexString (JG07))))
    CreateByteField (I2BU, 0xA5, JP07)
    ADBG (Concatenate ("JP07", Concatenate ("0x", ToHexString (JP07))))
    If (KN07)
    {
        If (CondRefOf (\_SB.PC00.I2C7))
        {
            Scope (\_SB.PC00.I2C7)
            {
                I2EN = KN07 /* \KN07 */
                Name (EPDO, Zero)
                EPDO = EE07 /* \EE07 */
                Name (PIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                PIRT [Zero] = GG07 /* \GG07 */
                PIRT [One] = GP07 /* \GP07 */
                Name (TPWR, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TPWR [Zero] = HG07 /* \HG07 */
                TPWR [One] = HP07 /* \HP07 */
                Name (TRST, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TRST [Zero] = IG07 /* \IG07 */
                TRST [One] = IP07 /* \IP07 */
                Name (TIRT, Package (0x02)
                {
                    Zero, 
                    Zero
                })
                TIRT [Zero] = JG07 /* \JG07 */
                TIRT [One] = JP07 /* \JP07 */
                If (I2EN)
                {
                    Method (PS0X, 0, Serialized)
                    {
                        ADBG ("I2c PS0 :0000000000000007")
                    }

                    Method (PS3X, 0, Serialized)
                    {
                        ADBG ("I2c PS3 :0000000000000007")
                    }

                    If ((EPDO & One))
                    {
                        PowerResource (PXTC, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (Zero))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Pad On Method :0000000000000007")
                                PON (Zero)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Pad Off Method :0000000000000007")
                                POFF (Zero)
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        PowerResource (PTPL, 0x00, 0x0000)
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (PSTA (One))
                            }

                            Method (_ON, 0, NotSerialized)  // _ON_: Power On
                            {
                                ADBG ("I2c Touch Panel On Method :0000000000000007")
                                PON (One)
                            }

                            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                            {
                                ADBG ("I2c Touch Panel Off Method :0000000000000007")
                                POFF (One)
                            }
                        }
                    }

                    Name (ONTM, Zero)
                    Method (PSTA, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("TPD _STA ON")
                            Return (One)
                        }

                        If ((Arg0 == One))
                        {
                            If ((DerefOf (TPWR [Zero]) == Zero))
                            {
                                ADBG ("TPL _STA is always ON")
                                Return (One)
                            }

                            If ((\_SB.GGOV (DerefOf (TPWR [Zero])) == One))
                            {
                                ADBG ("TPL _STA ON")
                                Return (One)
                            }
                            Else
                            {
                                ADBG ("TPL _STA OFF")
                                Return (Zero)
                            }
                        }

                        Return (Zero)
                    }

                    Method (PON, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR ON")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), One)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR ON")
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                \_SB.SGOV (DerefOf (TPWR [Zero]), DerefOf (TPWR [One]))
                                Sleep (0x02)
                            }

                            \_SB.SGOV (DerefOf (TRST [Zero]), DerefOf (TRST [One]))
                            ONTM = Timer
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), One)
                                }
                            }
                        }
                    }

                    Method (POFF, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            ADBG ("I2C Tpd PWR OFF")
                            If (CondRefOf (TPDM))
                            {
                                If ((TPDM == One))
                                {
                                    \_SB.SGRA (DerefOf (PIRT [Zero]), Zero)
                                }
                            }
                        }
                        ElseIf ((Arg0 == One))
                        {
                            ADBG ("I2C Touch PWR OFF")
                            If (CondRefOf (TPLM))
                            {
                                If ((TPLM == One))
                                {
                                    \_SB.SGRA (DerefOf (TIRT [Zero]), Zero)
                                }
                            }

                            Local0 = (DerefOf (TRST [One]) ^ One)
                            \_SB.SGOV (DerefOf (TRST [Zero]), Local0)
                            If ((DerefOf (TPWR [Zero]) != Zero))
                            {
                                Sleep (0x03)
                                Local0 = (DerefOf (TPWR [One]) ^ One)
                                \_SB.SGOV (DerefOf (TPWR [Zero]), Local0)
                            }

                            ONTM = Zero
                        }
                    }

                    If ((EPDO & One))
                    {
                        If (CondRefOf (TPD0))
                        {
                            Scope (TPD0)
                            {
                                Name (TD_N, "TPD0")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C7.PXTC
                                })
                                Alias (IC0D, TD_D)
                                Alias (\_SB.PC00.I2C7.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C7.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C7.TPD0.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }

                    If ((EPDO & 0x02))
                    {
                        If (CondRefOf (TPL1))
                        {
                            Scope (TPL1)
                            {
                                Name (TD_N, "TPL1")
                                Name (TD_P, Package (0x01)
                                {
                                    \_SB.PC00.I2C7.PTPL
                                })
                                Alias (IC1D, TD_D)
                                Alias (\_SB.PC00.I2C7.ONTM, TD_C)
                                Method (PS0X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D0"))
                                    If ((TD_C == Zero))
                                    {
                                        Return (Zero)
                                    }

                                    Local0 = ((Timer - TD_C) / 0x2710)
                                    Local1 = (TD_D + VRRD) /* External reference */
                                    If ((Local0 < Local1))
                                    {
                                        Sleep ((Local1 - Local0))
                                    }
                                }

                                Method (PS3X, 0, Serialized)
                                {
                                    ADBG (Concatenate (TD_N, " D3"))
                                }

                                Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C7.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                                {
                                    If ((_STA () == 0x0F))
                                    {
                                        Return (TD_P) /* \_SB_.PC00.I2C7.TPL1.TD_P */
                                    }
                                    Else
                                    {
                                        Return (Package (0x00){})
                                    }
                                }

                                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                                {
                                    PS0X ()
                                }

                                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                                {
                                    PS3X ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

