'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para almacenar los datos que se reciben por el puerto serial a una
' memoria SD
'


$regfile = "m328Pdef.dat"                                   ' used micro
$crystal = 16000000                                         ' used xtal
$baud = 9600                                                ' baud rate we want
$hwstack = 80
$swstack = 80
$framesize = 80

$projecttime = 31
$version 0 , 0 , 19



'Declaracion de constantes
Const Debugit = 1
Const Fosc = 32000000
Const Divider = 2 ^ 19
Const Frf = 868000000
Const Faktor = 2 ^ 24                                       'Used for frequency error calc
$include "SX1278_registers.inc"
Const Numtxaut = 1
Const Numtxaut_mas_uno = Numtxaut + 1

'Configuracion de entradas/salidas
Led1 Alias Portb.0                                          'LED ROJO
Config Led1 = Output

'LORA
_slaveselectpin Alias Portb.2
Config _slaveselectpin = Output                             'RFM92 nSEL OUT
Set _slaveselectpin

Dio0 Alias Pind.2
Config Dio0 = Input                                         ' INT pin for rx done/tx done etc. Programmable.

Nreset Alias Portc.1
Config Nreset = Output





'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 1024                     'Ints a 100Hz si Timer0=184
On Timer0 Int_timer0
Enable Timer0
Start Timer0

' Puerto serial 1
Open "com1:" For Binary As #1
On Urxc At_ser1
Enable Urxc

'-------SPI configuration-------------------------------------------------------
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 64 , Noss = 1 , Spiin = 0
Spiinit

Enable Interrupts

Config Base = 0                                             'Arreglos empiezan en 0 Ar(0)

'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "LORA_archivos.bas"


'Programa principal

Call Inivar()

Call Inilora()
Wait 3
Call Startreceiving

Do

   If Sernew = 1 Then                                       'DATOS SERIAL 1
      Reset Sernew
      Print #1 , "SER1=" ; Serproc
      Call Procser()
   End If

   Test_byte = Readregister(loraregirqflags)                'test for ValidHeader bit 4
   If Test_byte.4 = 1 Then
     Call Writeregister(loraregirqflags , &H10)          'reset irq flag bit 4
     _rssi = Lorareadrssi()
     Print #1 , "RSSI for Lora: " ; _rssi
   End If

   If Dio0 = 1 Then
      Call Receivemessage
      _pktsnr = Lorapktsnr()
      Print #1 , "SNR: " ; _pktsnr
      _pktrssi = Lorapktrssi()
      Print #1 , "Packet RSSI: " ; _pktrssi
      _lorafei = Lorafei()
      Print #1 , "Recived: " ; Receive_string
'      For J = 1 To 16
'         Print #1 , Chr(rx(j));
'      Next
'      Print #1,
   End If

Loop