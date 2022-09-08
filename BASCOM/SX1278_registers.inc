' // ----------------------------------------
'// Registers Mapping
Const Regfifo = &H00                                        '/ / Common
Const Regopmode = &H01                                      ' / / Common
Const Fskregbitratemsb = &H02
Const Fskregbitratelsb = &H03
Const Fskregfdevmsb = &H04
Const Fskregfdevlsb = &H05
Const Regfrfmsb = &H06                                      '/ / Common
Const Regfrfmid = &H07                                      '/ / Common
Const Regfrflsb = &H08                                      '/ / Common
Const Regpaconfig = &H09                                    ' / / Common
Const Regparamp = &H0A                                      '/ / Common
Const Regocp = &H0B                                         '/ / Common
Const Reglna = &H0C                                         '/ / Common
Const Fskregrxconfig = &H0D
Const Loraregfifoaddrptr = &H0D
Const Fskregrssiconfig = &H0E
Const Loraregfifotxbaseaddr = &H0E
Const Fskregrssicollision = &H0F
Const Loraregfiforxbaseaddr = &H0F
Const Fskregrssithresh = &H10
Const Loraregfiforxcurrentaddr = &H10
Const Fskregrssivalue = &H11
Const Loraregirqflagsmask = &H11
Const Fskregrxbw = &H12
Const Loraregirqflags = &H12
Const Fskregafcbw = &H13
Const Loraregrxnbbytes = &H13
Const Fskregookpeak = &H14
Const Loraregrxheadercntvaluemsb = &H14
Const Fskregookfix = &H15
Const Loraregrxheadercntvaluelsb = &H15
Const Fskregookavg = &H16
Const Loraregrxpacketcntvaluemsb = &H16
Const Loraregrxpacketcntvaluelsb = &H17
Const Loraregmodemstat = &H18
Const Loraregpktsnrvalue = &H19
Const Fskregafcfei = &H1A
Const Loraregpktrssivalue = &H1A
Const Fskregafcmsb = &H1B
Const Loraregrssivalue = &H1B
Const Fskregafclsb = &H1C
Const Lorareghopchannel = &H1C
Const Fskregfeimsb = &H1D
Const Loraregmodemconfig1 = &H1D
Const Fskregfeilsb = &H1E
Const Loraregmodemconfig2 = &H1E
Const Fskregpreambledetect = &H1F
Const Loraregsymbtimeoutlsb = &H1F
Const Fskregrxtimeout1 = &H20
Const Loraregpreamblemsb = &H20
Const Fskregrxtimeout2 = &H21
Const Loraregpreamblelsb = &H21
Const Fskregrxtimeout3 = &H22
Const Loraregpayloadlength = &H22
Const Fskregrxdelay = &H23
Const Loraregpayloadmaxlength = &H23
Const Fskregosc = &H24
Const Lorareghopperiod = &H24
Const Fskregpreamblemsb = &H25
Const Loraregfiforxbyteaddr = &H25
Const Loraregmodemconfig3 = &H26
Const Fskregpreamblelsb = &H26
Const Fskregsyncconfig = &H27
Const Loraregfeimsb = &H28
Const Fskregsyncvalue1 = &H28
Const Loraregfeimib = &H29
Const Fskregsyncvalue2 = &H29
Const Loraregfeilsb = &H2A
Const Fskregsyncvalue3 = &H2A
Const Fskregsyncvalue4 = &H2B
Const Loraregrssiwideband = &H2C
Const Fskregsyncvalue5 = &H2C
Const Fskregsyncvalue6 = &H2D
Const Fskregsyncvalue7 = &H2E
Const Fskregsyncvalue8 = &H2F
Const Fskregpacketconfig1 = &H30
Const Fskregpacketconfig2 = &H31
Const Loraregdetectoptimize = &H31
Const Fskregpayloadlength = &H32
Const Fskregnodeadrs = &H33
Const Lorareginvertiq = &H33
Const Fskregbroadcastadrs = &H34
Const Fskregfifothresh = &H35
Const Fskregseqconfig1 = &H36
Const Fskregseqconfig2 = &H37
Const Loraregdetectionthreshold = &H37
Const Fskregtimerresol = &H38
Const Fskregtimer1coef = &H39
Const Loraregsyncword = &H39
Const Fskregtimer2coef = &H3A
Const Fskregimagecal = &H3B
Const Fskregtemp = &H3C
Const Fskreglowbat = &H3D
Const Fskregirqflags1 = &H3E
Const Fskregirqflags2 = &H3F

Const Regversion = &H42                                     '/ / Common

Const Regpadac = &H5A                                       '// common

'****   MODES ****************
Const SX1278_mode_rx_continuos = &H8D
Const SX1278_mode_tx = &H8B
Const SX1278_mode_sleep = &H08
Const Sx1278_mode_standby = &H09
'******************************

Const Payload_length = &H0A                                 '10 bytes
Const Implicit_mode = &H0C

'  / / Power Amplifier Config
'b7=0 RFIO pin. Output power is limited to 13 dBm.
'b7=1 PA_BOOST pin. Output power is limited to 20 dBm
'RegPaDac 0x5A 20dbm=0x87 17dbm=0x84(default)
Const Reg_pa_config = &H09
Const Pa_20dbm = &HFF                                       '20dbm
Const Pa_17dbm = &HFC                                       '17dbm
Const Pa_14dbm = &HF9                                       '14dbm
Const Pa_11dbm = &HF6                                       '11dbm
Const Pa_off_boost = &H0F                                   'PA off,max on rfio pin=13dbm
'*** SX1278 dorji**
'  0xFF                    '//20dbm
'  0xFC                    '//17dbm
'  0xF9                    '//14dbm
'  0xf6 ,                  '/ 11dbm

'// LOW NOISE AMPLIFIER
Const Reg_lna = &H0C
Const Lna_max_gain = &H23                                   '0010_0011 Max gain,boost ON
Const Lna_off_gain = &H20                                   '0010_0000 Max gain,no boost

'DIO mapping
Const Reg_dio_mapping_1 = &H40
Const Reg_dio_mapping_2 = &H41