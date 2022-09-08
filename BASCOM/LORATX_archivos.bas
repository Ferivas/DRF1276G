'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*  SD_Archivos.bas                                                        *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*                                                                             *
'*  Variables, Subrutinas y Funciones                                          *
'* WATCHING SOLUCIONES TECNOLOGICAS                                            *
'* 25.06.2015                                                                  *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

$nocompile


'*******************************************************************************
'Declaracion de subrutinas
'*******************************************************************************
Declare Sub Inivar()
Declare Sub Procser()
Declare Sub Setloramode
Declare Sub Startreceiving
Declare Sub Setmode(byval Newmode As Byte)
Declare Sub Receivemessage
Declare Sub Senddata
Declare Function Lorareadrssi() As Integer
Declare Function Lorapktsnr() As Integer
Declare Function Lorapktrssi() As Integer
Declare Function Lorafei() As Long

Declare Sub Writeregister(byval Addr As Byte , Byval Value As Byte)
Declare Sub Fifo_burst_write(byval Start_at As Byte , Byval Length As Byte)
Declare Sub Fifo_burst_read(fifo_pointer As Byte , Length As Byte)       'ALL Passed byref
Declare Function Readregister(byval Address As Byte) As Byte
Declare Sub Rstlora()
Declare Sub Inilora()

'*******************************************************************************
'Declaracion de variables
'*******************************************************************************
Dim Tmpb As Byte
Dim Tmpl As Long , Tmpl2 As Long , Tmplisr As Long , Lsyssec As Long
Dim Jt1 As Byte , Jt0 As Byte
Dim Cmdtmp As String * 6
Dim Atsnd As String * 200
Dim Cmderr As Byte
Dim Tmpstr8 As String * 16
Dim Tmpstr52 As String * 52
Dim Cntrtx As Byte
'Variables para transmisiones automáticas
Dim Autoval(numtxaut) As Long , Autovaleep(numtxaut) As Eram Long
Dim Offset(numtxaut) As Long , Offseteep(numtxaut) As Eram Long
Dim Iniauto As Byte

'LORA variables
Dim Currentmode As Byte
Currentmode = Sx1278_mode_standby
Dim Rx(65) As Byte
Dim Receive_string As String * 64 At Rx(0) Overlay
Dim Tx(65) As Byte
Dim Send_string As String * 64 At Tx(0) Overlay

Dim J As Byte
Dim Test_byte As Byte
Dim _rssi As Integer
Dim _pktsnr As Integer
Dim _pktrssi As Integer
Dim _lorafei As Integer

'CALCULATE REQUIRED FREQUENCY REGISTERS OR SET THEM DIRECTLY
Dim Freg(3) As Byte
Dim Lfreg As Dword At Freg Overlay
Dim Aa As Single
Dim Bb As Single
Aa = Fosc / Divider
Bb = Frf / Aa
Lfreg = Bb

'Variables TIMER0
Dim T0c As Byte
Dim Num_ventana As Byte
Dim Estado As Long
Dim Estado_led As Byte
Dim Iluminar As Bit
Dim T00 As Byte
Dim Newsec As Byte
Dim T0cntr As Word
Dim T0tout As Bit , T0ini As Bit
Dim T0rate As Word

'Variables SERIAL0
Dim Ser_ini As Bit , Sernew As Bit
Dim Numpar As Byte
Dim Cmdsplit(6) As String * 32
Dim Serdata As String * 140 , Serrx As Byte , Serproc As String * 140



'*******************************************************************************
'* END public part                                                             *
'*******************************************************************************


Goto Loaded_arch

'*******************************************************************************
' INTERRUPCIONES
'*******************************************************************************

'*******************************************************************************
' Subrutina interrupcion de puerto serial 1
'*******************************************************************************
At_ser1:
   Serrx = Udr

   Select Case Serrx
      Case "$":
         Ser_ini = 1
         Serdata = ""

      Case 13:
         If Ser_ini = 1 Then
            Ser_ini = 0
            Serdata = Serdata + Chr(0)
            Serproc = Serdata
            Sernew = 1
            'Enable Timer0
         End If

      Case Is > 31
         If Ser_ini = 1 Then
            Serdata = Serdata + Chr(serrx)
         End If

   End Select

Return


Return

'*******************************************************************************



'*******************************************************************************
' TIMER0
'*******************************************************************************
Int_timer0:
   Timer0 = &H8B           '100.1603hZ
   Incr T0c
   T0c = T0c Mod 8
   If T0c = 0 Then
      Num_ventana = Num_ventana Mod 32
      Estado = Lookup(estado_led , Tabla_estado)
      Iluminar = Estado.num_ventana
      Toggle Iluminar
      Led1 = Iluminar
      Incr Num_ventana
   End If
   Incr T00
   T00 = T00 Mod 100
   If T00 = 0 Then
      Set Newsec
      Incr Lsyssec
      For Jt1 = 1 To Numtxaut
         Tmplisr = Lsyssec + Offset(jt1)
         Tmplisr = Tmplisr Mod Autoval(jt1)
         Jt0 = Jt1 - 1
         If Tmplisr = 0 Then Set Iniauto.jt0
      Next
   End If

   If T0ini = 1 Then
      Incr T0cntr
      If T0cntr = T0rate Then
         Set T0tout
      End If
   Else
      T0cntr = 0
   End If

Return





'*******************************************************************************
' SUBRUTINAS
'*******************************************************************************

'*******************************************************************************
' Inicialización de variables
'*******************************************************************************
Sub Inivar()
   Reset Led1
   Print #1 , Version(1)
   Print #1 , Version(2)
   Print #1 , Version(3)
   Estado_led = 1

   For Tmpb = 1 To Numtxaut
      Autoval(tmpb) = Autovaleep(tmpb)
      Offset(tmpb) = Offseteep(tmpb)
      Print #1 , "Aut" ; Tmpb ; "=" ; Autoval(tmpb) ; ", OFF" ; Tmpb ; "=" ; Offset(tmpb)
   Next


End Sub


'*******************************************************************************
' Procesamiento de comandos
'*******************************************************************************
Sub Procser()
   Print #1 , "$" ; Serproc
   Tmpstr52 = Mid(serproc , 1 , 6)
   Numpar = Split(serproc , Cmdsplit(1) , ",")
   If Numpar > 0 Then
      For Tmpb = 1 To Numpar
         Print #1 , Tmpb ; ":" ; Cmdsplit(tmpb)
      Next
   End If

   If Len(cmdsplit(1)) = 6 Then
      Cmdtmp = Cmdsplit(1)
      Cmdtmp = Ucase(cmdtmp)
      Cmderr = 255
      Select Case Cmdtmp
         Case "LEEVFW"
            Cmderr = 0
            Atsnd = "Version FW: Fecha <"
            Tmpstr52 = Version(1)
            Atsnd = Atsnd + Tmpstr52 + ">, Archivo <"
            Tmpstr52 = Version(3)
            Atsnd = Atsnd + Tmpstr52 + ">"


         Case "SETLED"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb < 17 Then
                  Cmderr = 0
                  Atsnd = "Se configura setled a " + Str(tmpb)
                  Estado_led = Tmpb

               Else
                  Cmderr = 5
               End If

            Else
               Cmderr = 4

            End If

         Case "SETAUT"
            If Numpar = 3 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 'Snstr = Cmdsplit(3)
                 Tmpl2 = Val(cmdsplit(3))
                 Autoval(j) = Tmpl2
                 Autovaleep(j) = Tmpl2
                 Cmderr = 0
                 'Print #1 , "$" ; J ; "," ; Autoval(j)
                 'Print #1 , "$OK"
                 Atsnd = "Se configuro tx AUT " + Str(j) + ":" + Str(autoval(j))
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "SETOFF"
            If Numpar = 3 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 'Snstr = Cmdsplit(3)
                 Tmpl2 = Val(cmdsplit(3))
                 Offset(j) = Tmpl2
                 Offseteep(j) = Tmpl2
                 Cmderr = 0
                 Atsnd = "Se configuro tx AUT " + Str(j) + ":" + Str(offset(j))
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEAUT"                                      'Habilitaciones de Usuario
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  'Snstr = Cmdsplit(3)
                  Atsnd = "Tx Aut " + Str(j) + ":" + Str(autoval(j))
                  Cmderr = 0
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEOFF"                                      'Habilitaciones de Usuario
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 'Snstr = Cmdsplit(3)
                  Atsnd = "Offset Aut " + Str(j) + ":" + Str(offset(j))
                  Cmderr = 0
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If


         Case "SETNEW"
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  Cmderr = 0
                  Tmpb = J - 1
                  Set Iniauto.tmpb
                  Atsnd = "Se activo Tx. AUT " + Str(j) + "," + Bin(iniauto)
               Else
                  Cmderr = 3
               End If

            Else
               Cmderr = 4
            End If

         Case Else
            Cmderr = 1

      End Select

   Else
        Cmderr = 2
   End If

   If Cmderr > 0 Then
      Atsnd = Lookupstr(cmderr , Tbl_err)
   End If

   Print #1 , Atsnd

End Sub

'*******************************************************************************
' Subs y Func LoRa
'*******************************************************************************
'Read a Register Byte from RFM92
Function Readregister(byval Address As Byte) As Byte
   Reset _slaveselectpin
   Address = Address And &H7F
   Spiout Address , 1                                       'write register address
   Spiin Readregister , 1                                   'store register value in Readregister
   Set _slaveselectpin
End Function

Sub Writeregister(byval Addr As Byte , Byval Value As Byte)
   Reset _slaveselectpin                                    ' RFM92 Slave Select
   Set Addr.7                                               'Set write bit
   Spiout Addr , 1                                          ' Write Address
   Spiout Value , 1                                         ' Write Data Byte
   Set _slaveselectpin
End Sub

Sub Fifo_burst_read(fifo_pointer As Byte , Length As Byte)  'ALL Passed byref
   Local X As Byte , Y As Byte
   X = Regfifo                                              'Address for FIFO read
   Y = Fifo_pointer                                         'Start value to fill the Rx() Array
   Length = Fifo_pointer + Length
   Length = Length - 1                                      'Rx(1) ....Rx(32)   next is   Rx(33) ...Rx(64)  next is  Rx(65) ....Rx(96)
   Reset _slaveselectpin
   Spiout X , 1                                             'write fifo register address only once
    For X = Y To Length
       Spiin Rx(x) , 1                                      'Read the FIFO in burst mode
    Next
   Set _slaveselectpin
End Sub

Sub Fifo_burst_write(byval Start_at As Byte , Byval Length As Byte)
   Local X As Byte , Y As Byte
   X = Regfifo
   If Start_at = 0 Then Y = Length                          'Tx(1) ....Tx(64)  -->  Tx(65) .....Tx(96)
   If Start_at > 0 Then
      Y = Start_at + Length                                 '65 + 32 = 97 - 1 = 96   .....
      Y = Y - 1
   End If
   Set X.7                                                  'Set write bit
   Reset _slaveselectpin
   Spiout X , 1                                             'write fifo register address only once
    For X = Start_at To Y
       Spiout Tx(x) , 1                                     'Write the FIFO in burst mode
    Next
   Set _slaveselectpin
End Sub

Sub Setloramode
'Method:   Enable LoRa mode
   Print #1,  "Setting LoRa Mode"
   Call Setmode(SX1278_mode_sleep)
   Waitms 400
   Call Writeregister(regopmode , &H88)
   Print #1,  "LoRa Mode Set"
End Sub

Sub Startreceiving
'********************************************
'Method:   Setup to receive continuously

'  // Turn on implicit header mode and set payload length
   'Call Writeregister(reg_modem_config , Implicit_mode)
   Call Writeregister(loraregpayloadlength , Payload_length)
   'Call Writeregister(reg_hop_period , &HFF)
   Call Writeregister(loraregfifoaddrptr , Readregister(loraregfiforxbaseaddr))

  '// Setup Receive Continous Mode
   Call Setmode(SX1278_mode_rx_continuos)
End Sub

Sub Receivemessage
'Method:   Receive FROM BUFFER

         Local X_r As Byte
         Local Currentaddr As Byte
         Local Receivedcount As Byte
         Local I As Byte

         'clear the rxDone flag
         Call Writeregister(loraregirqflags , &H40)         '&B0100_0000
         X_r = Readregister(loraregirqflags)                ' // if any of these are set then the inbound message failed
         Print #1,  "IRQFLAGS: " ; Bin(x_r)

  '// check for payload crc issues (0x20 is the bit we are looking for
  If X_r.5 = 1 Then                                         'IRQ crc error set?
         Print #1,  "Oops there was a crc problem!!"
         Print #1,  X_r
    ' / / Reset The Crc Flags
         Call Writeregister(loraregirqflags , &H20)         '&B0010_0000
  Else
         Currentaddr = Readregister(loraregfiforxcurrentaddr)
         Receivedcount = Readregister(loraregrxnbbytes)
         'Receivedcount = Receivedcount + 1
         Print #1,  "Packet! RX Current Addr: " ; Currentaddr;
         Print #1,  "Number of bytes received: " ; Receivedcount

         Call Writeregister(loraregfifoaddrptr , Currentaddr)
         'now loop over the fifo getting the data
         I = 0
         While I < Receivedcount
            Rx(i) = Readregister(regfifo)
            Incr I
         Wend
  End If

End Sub

Sub Setmode(byval Newmode As Byte)
' Method:   Change the mode

   If Newmode = Currentmode Then
      Exit Sub
   End If
   Select Case Newmode

      Case SX1278_mode_rx_continuos
         'Call Writeregister(lorareghopperiod , &HFF)        '  **** MÅ TESTES!!!!!!!!!!!!
         Call Writeregister(reg_pa_config , &H00)           '  // TURN PA OFF FOR RECIEVE??
         Call Writeregister(reg_lna , Lna_max_gain)         '  // MAX GAIN FOR RECIEVE
         Call Writeregister(regopmode , Newmode)
         Currentmode = Newmode
         Print #1,  "Changing to Receive Continous Mode"

      Case Sx1278_mode_tx
         'Call Writeregister(lorareghopperiod , &H00)        '0=disabled  **** MÅ TESTES!!!!!!!!!!!!
         Call Writeregister(reg_lna , Lna_off_gain)         '  // TURN LNA OFF FOR TRANSMITT
         Call Writeregister(reg_pa_config , Pa_14dbm)       '    // TURN PA TO MAX POWER
         Call Writeregister(regopmode , Newmode)
         Currentmode = Newmode
         Print #1,  "Changing to Transmit Mode"

      Case SX1278_mode_sleep
         Call Writeregister(regopmode , Newmode)
         Currentmode = Newmode
         Print #1,  "Changing to Sleep Mode"

      Case SX1278_mode_standby
         Call Writeregister(regopmode , Newmode)
         Currentmode = Newmode
         Print #1,  "Changing to Standby Mode"

   End Select
   Print #1,  " Mode Change Done"
End Sub

Sub Senddata
Local X As Byte
   X = Regfifo
  Call Setmode(SX1278_mode_standby)
  Call Writeregister(loraregfifotxbaseaddr , &H00)          'Update the address ptr to the current tx base address
  Call Writeregister(loraregfifoaddrptr , &H00)
  Call Fifo_burst_write(1 , 11)
  'Go into transmit mode
  Call Setmode(sx1278_mode_tx)
  ' once TxDone has flipped, everything has been sent

   T0rate = 200
   T0cntr = 0
   Set T0ini
   Reset T0tout

  While Dio0 = 0 And T0tout = 0
      'Print #1,  "y"
  Wend
  If Dio0 = 0 Then
   Print #1 , " done sending!"
  Else
   Print #1 , "tIMEOUT"
  End If
  '// clear the flags 0x08 is the TxDone flag
  Call Writeregister(loraregirqflags , &H08)
  'Blink the LED

End Sub

'/**********************************************************
'**Name:     LoRaReadRSSI
'**Function: Read the RSSI value
'**Input:    none
'**Output:   temp, RSSI value
'**********************************************************/
Function Lorareadrssi() As Integer
  Local Temp1 As Integer
  Local Rssi_mean As Integer
  Local Cntr As Byte
  Local Bbyte As Byte
  Rssi_mean = 0
  Temp1 = 0
  Cntr = 0
   While Cntr < 5
    Bbyte = Readregister(loraregrssivalue)
    Temp1 = -164 + Bbyte
    Rssi_mean = Rssi_mean + Temp1
    Incr Cntr
   Wend
   Rssi_mean = Rssi_mean \ 5
   Lorareadrssi = Rssi_mean
End Function

Function Lorapktsnr() As Integer
Local Test_byte As Byte
      Test_byte = Readregister(loraregpktsnrvalue)          'Get packet SNR
      If Test_byte.7 = 1 Then                               'If negative number
         Test_byte = Not Test_byte
         Test_byte = Test_byte + 1
         Shift Test_byte , Right , 2                        'divide by 4
         Lorapktsnr = - Test_byte
      Else
         Shift Test_byte , Right , 2                        'divide by 4
         Lorapktsnr = Test_byte
      End If
End Function

Function Lorapktrssi() As Integer
Local Test_byte As Byte
Local Temp1 As Integer
Local Temp2 As Integer
      Temp2 = Lorapktsnr()
      If Temp2 > 0 Then
         Test_byte = Readregister(loraregpktrssivalue)
         Print #1,  "pktrssi_raw " ; Test_byte
         Temp1 = Test_byte
         'Temp1 = Temp1 \ 4  'This is stated in SX1272 manual, but corrected in reg desc.
         Temp1 = -164 + Temp1
         Lorapktrssi = Temp1
      Else
         Test_byte = Readregister(loraregpktrssivalue)
         Temp2 = Temp2 \ 4                                  'FORMULA from waspmote: pktssi(BW=125)=-174+10*5.1+6+SNR
         Temp2 = Test_byte + Temp2
         Temp1 = -164 + Temp2
         Lorapktrssi = Temp1
      End If
End Function

'*** Reads frequency error based on 3 bytes giving 20bit 2's complement value
'*** 'FError=FreqError x 2^24/Fxtal  * BW/500
Function Lorafei() As Long
Local Abyte As Byte
Local L1 As Long
Local L2 As Long

      #if Debugit = 1
          Abyte = Readregister(loraregfeimsb)               'MSB of fei
          Print #1,  "FEIREGS: " ; Hex(abyte);
          Abyte = Readregister(loraregfeimib)               'MID of fei
          Print #1,  Hex(abyte);
          Abyte = Readregister(loraregfeilsb)               'LSB of fei
          Print #1,  Hex(abyte)
      #endif

      Abyte = Readregister(loraregfeimsb)                   'MSB of fei
      If Abyte.3 = 1 Then                                   'Negative number
         L1 = Abyte * 65536
         Abyte = Readregister(loraregfeimib)                'MID of fei
         L2 = Abyte * 256
         L1 = L1 + L2
         Abyte = Readregister(loraregfeilsb)                'LSB of fei
         L1 = L1 + Abyte
         L1 = Not L1
         L1 = L1 + 1
         #if Debugit = 1
           Print #1,  "L1 negative " ; L1
         #endif
      Else
         'Abyte = Readregister(loraregfeimsb)                   'MSB of fei
         L1 = Abyte * 65536
         Abyte = Readregister(loraregfeimib)                'MID of fei
         L2 = Abyte * 256
         L1 = L1 + L2
         Abyte = Readregister(loraregfeilsb)                'LSB of fei
         L1 = L1 + Abyte
         #if Debugit = 1
           Print #1,  "L1 positive " ; L1
         #endif
      End If
      L1 = L1 * Faktor
      L1 = L1 / Fosc
      #if Debugit = 1
           Print #1,  "lorafei= " ; L1
      #endif
      Lorafei = L1

End Function

Sub Rstlora()
   Reset Nreset
   Waitms 20
   Set Nreset
   Waitms 20
End Sub

Sub Inilora()
   Call Rstlora()
   Call Setloramode                                         ' also puts it to sleep
   'HERE THE FREQUENCY ARE SET DIRECTLY FOR TESTING
   'Print #1,  "msb " ; Hex(freg(2))
   'Print #1,  "mid " ; Hex(freg(1))
   'Print #1,  "lsb " ; Hex(freg(0))
   Call Writeregister(regfrfmsb , Freg(2))
   Call Writeregister(regfrfmid , Freg(1))
   Call Writeregister(regfrflsb , Freg(0))

   '0x6c8000 = 434 MHz.
   'Call Writeregister(regfrfmsb , &H6C)                        'TEST
   'Call Writeregister(regfrfmid , &H80)                        'TEST
   'Call Writeregister(regfrflsb , &H00)                        'TEST

   'setting base parameter
   Call Writeregister(reg_pa_config , Pa_14dbm)                'Setting output power parameter

   Call Writeregister(regocp , &H0B)                           'RegOcp,Close Ocp

   Call Writeregister(reglna , &H23)                           'Reglna , High & Lna Enable

   Call Writeregister(loraregmodemconfig1 , &H72)              '72=125khz,4/5,explicite &H73=125khz,4/5,implicite

   Call Writeregister(loraregmodemconfig2 , &HC3)              '1100=SF12, 0=Txcont, 1=CRCon, 11=Rxtimeout

   Call Writeregister(loraregdetectoptimize , &HC3)            '&H31 Lora detectoptimize SF7 to SF12
   'Call Writeregister(loraregdetectoptimize , &HC5)                            'Lora detectoptimize SF6

   Call Writeregister(loraregdetectionthreshold , &H0A)        '&H37 detection thresold =0A for SF 7-12, OC for SF6

   Call Writeregister(loraregsymbtimeoutlsb , &HFF)            'RegSymbTimeoutLsb Timeout = 0x3FF(Max)

   Call Writeregister(loraregpreamblemsb , &H00)

   Call Writeregister(loraregpreamblelsb , 12)                 'Regpreamblelsb 8 + 4 = 12byte Preamble

   Test_byte = Readregister(loraregmodemconfig3)
   Print #1,  "Modem3 " ; Bin(test_byte)
   'b3=LowDataRateOptimize rw 0x00 0=Disabled,1=Enabled; mandated for when the symbol length exceeds 16ms
   'b2=AgcAutoOn rw 0x00 0=LNA gain set by register LnaGain, 1=Lna Gain Set By The Internal Agc Loop

   Test_byte = Readregister(loraregmodemconfig1)
   Print #1,  "modconf1: " ; Bin(test_byte)
   Test_byte = Readregister(loraregmodemconfig2)
   Print #1,  "modconf2: " ; Bin(test_byte)

   Test_byte = Readregister(regfrfmsb)
   Print #1,  "Frf_MSB: " ; Hex(test_byte)
   Test_byte = Readregister(regfrfmid)
   Print #1,  "Frf_MID: " ; Hex(test_byte)
   Test_byte = Readregister(regfrflsb)
   Print #1,  "Frf_LSB: " ; Hex(test_byte)
   '// Go to standby mode
   Call Setmode(sx1278_mode_standby)
   Print #1,  "Setup Complete"

End Sub

'*******************************************************************************
'TABLA DE DATOS
'*******************************************************************************

Tbl_err:
Data "OK"                                                   '0
Data "Comando no reconocido"                                '1
Data "Longitud comando no valida"                           '2
Data "Numero de usuario no valido"                          '3
Data "Numero de parametros invalido"                        '4
Data "Error longitud parametro 1"                           '5
Data "Error longitud parametro 2"                           '6
Data "Parametro no valido"                                  '7
Data "ERROR8"                                               '8
Data "ERROR SD. Intente de nuevo"                           '9

Tabla_estado:
Data &B00000000000000000000000000000000&                    'Estado 0
Data &B00000000000000000000000000000011&                    'Estado 1
Data &B00000000000000000000000000110011&                    'Estado 2
Data &B00000000000000000000001100110011&                    'Estado 3
Data &B00000000000000000011001100110011&                    'Estado 4
Data &B00000000000000110011001100110011&                    'Estado 5
Data &B00000000000011001100000000110011&                    'Estado 6
Data &B00001111111111110000111111111111&                    'Estado 7
Data &B01010101010101010101010101010101&                    'Estado 8
Data &B00110011001100110011001100110011&                    'Estado 9
Data &B01110111011101110111011101110111&                    'Estado 10
Data &B11111111111111000000000000001100&                    'Estado 11
Data &B11111111111111000000000011001100&                    'Estado 12
Data &B11111111111111000000110011001100&                    'Estado 13
Data &B11111111111111001100110011001100&                    'Estado 14
Data &B11111111111111000000000000001100&                    'Estado 15
Data &B11111111111111111111111111110000&                    'Estado 16



Loaded_arch: