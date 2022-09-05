
# Basado en ESP32 conectado a  modulo DRF1276G
# Los pines utilizados se configuran en controller_esp32.py
import config_lora
from sx127x import SX127x
from controller_esp32 import ESP32Controller
from time import sleep
from machine import UART
from machine import Pin, I2C
import machine
import ubinascii
from ssd1306_i2c import Display
#****************************************************************
#   Pines y configuracion
#****************************************************************
ledrx=Pin(12,Pin.OUT)
ledrx.value(1)
sleep(1)
ledrx.value(0)

#OLED
rst = Pin(16, Pin.OUT)
rst.value(0)
sleep(0.10)
rst.value(1)
# Setup the I2C lines
i2c_scl = Pin(15, Pin.OUT, Pin.PULL_UP)
i2c_sda = Pin(4, Pin.OUT, Pin.PULL_UP)

display = Display()
display.show_text_wrap("LoRa NIVEL")

#Led Board
led=Pin(25,Pin.OUT)
#Serial
ser = UART(2,tx=17,rx=13,timeout=1)
#Timer
timer = machine.Timer(1)
#****************************************************************
#INTERRUPCIONES
#****************************************************************
timerflag=False
cntrt=0
cntrf=0
inirx=False
iniflash=False
def handleInterrupt(timer):
  global tled
  global timerflag
  global cntrt
  global cntrf
  global iniflash
  if inirx:  
      cntrt=cntrt+1
      cntrt=cntrt%40  #Int Timer cada 2 segundos
      if cntrt==0:
        timerflag=True
  if iniflash:
      ledrx.value(1)
      cntrf=cntrf+1
      cntrf=cntrf%2
      if cntrf==0:
          iniflash=False
          ledrx.value(0)
      
  tled=tled+1
  tled=tled%16
  if tled <1:
    led.value(1)
  else:
    led.value(0)

staed1="-"
staed2="-"
fechaloc="dd.mm.yy"
horaloc="hh:mm"
staremoto1="-"
staremoto2="-"
fecharem="dd.mm.yy"
horarem="hh:mm"
rssival="-----"
cntrtx="--"
cntrrx="--"

def display_data():
  txt=fechaloc+","+horaloc
  display.show_text(txt,0,0)
  txt="L1="+staed1+" L2="+staed2
  display.show_text(txt,0,10,False)
  txt=fecharem+","+horarem
  display.show_text(txt,0,20,False)
  txt="R1="+staremoto1+" R2="+staremoto2
  display.show_text(txt,0,30,False)
  txt="RSSI="+rssival
  display.show_text(txt,0,40,False)
  txt="T"+cntrtx+",R"+cntrrx
  display.show_text(txt,0,50,False)  

controller = ESP32Controller()
lora = controller.add_transceiver(SX127x(name = 'LoRa'),
                                  pin_id_ss = ESP32Controller.PIN_ID_FOR_LORA_SS,
                                  pin_id_RxDone = ESP32Controller.PIN_ID_FOR_LORA_DIO0)

ser.init(9600, bits=8, parity=None, stop=1,timeout=1)
timer = machine.Timer(1) 
tled=0
timer.init(period=100, mode=machine.Timer.PERIODIC, callback=handleInterrupt)
counter=0
print("LORA NIVEL TX/RX")

display_data()

while True:
  try:
      arxb=ser.readline()
  except:
      arxb=None
      
  if lora.receivedPacket():
    print("RX LORA MAIN")
    lora.blink_led()
    try:
        payload = lora.read_payload()
        datalora=str(payload.decode("ascii"))
        print(datalora,lora.packetRssi())
        rssi=lora.packetRssi()
        try:
            rssival=str(rssi)
        except:
            rssival="****"
        trama=datalora.split(',')
        datob=str.encode(datalora)
        crccalc=ubinascii.crc32(datob)
        crchex=hex(crccalc)
        crchex=crchex[2:]
        crchex=crchex.upper()
        salida="%"+datalora+'&'+crchex+'\r\n'
        ser.write(salida)
        if len(trama)==12:
            print("Trama OK")
            try:
                payload="OK"
                lora.println(payload)
            except:
                print("Err LoRa tx")
            salida='%SETOUT;'+trama[5]+';'+trama[6]+'\r\n'
            print(salida)
            ser.write(salida)            
            payload="OK"
            lora.println(payload)
            try:
              txttmp=trama[1]
              fecharem=txttmp.replace("/",".")
              txttmp=trama[2]
              horarem=txttmp[0:5]
              staremoto1=trama[5]
              staremoto2=trama[6]
              cntrrx=trama[9]
              display_data()
                  
            except:
                print("Err oled rx")
                
        else:
            print("Rama ERR")
    except Exception as e:
        print(e)    
    
  if arxb!=None:
    try:
      arx=str(arxb.decode("ascii"))
    except:
      arxb=None
      arx=''
    if len(arx)>0:
      if arx[0]=='$':
        print(arx)
        #salida="$OK"
        arx1=arx[1:]
        lista=arx1.split('&')
        if len(lista)==2:
          print(lista[1])
          datob=str.encode(lista[0])
          crccalc=ubinascii.crc32(datob)
          #print("CRCcal=",crccalc)    
          crcval='0x'+lista[1]
          try:
            crcdec=int(crcval,0)
          except:
            crcdec=0
          #print("CRCrx=",crcdec)
          if crccalc==crcdec:
            print('CRC OK')
            salida='%OK\r\n'
            ser.write(salida)
            print("SND LORA")
            #print(lista[0])
            trama=lista[0].split(',')
            print(trama)
            if len(trama)==12:
              try:
                  txttmp=trama[1]
                  fechaloc=txttmp.replace("/",".")
                  txttmp=trama[2]
                  horaloc=txttmp[0:5]
                  staed1=trama[5]
                  staed2=trama[6]
                  cntrtx=trama[9]
                  display_data()
              except:
                  print("Err OLED")
              try:
                print("SND LORA")
                payload = lista[0]
                ledrx.value(1)
                print("Sending packet")
                lora.println(payload)
                ledrx.value(0)
                inirx=True
                while not timerflag:
                    if lora.receivedPacket():
                        print("RX LORA")
                        payload = lora.read_payload()
                        datalora=str(payload.decode("ascii"))
                        print(datalora,lora.packetRssi())
                        if datalora=="OK":
                            timerflag=True
                            iniflash=True
                            print("ACK")
                print("OUT")        
                inirx=False
                timerflag=False
              except:
                print('ERROR TX IOT')
            else:

              print('Trama no val')
          else:
            print('CRC ERROR')
            salida='%ERR\r\n'
            ser.write(salida)          
        else:
          print('SIN CRC')
      else:
        #salida='%ERR\r\n'
        #ser.write(salida)
        print('Sin $')

#payload = 'Hello ({0})'.format(counter)
#print("Sending packet: \n{}\n".format(payload))
#lora.println(payload)
#counter += 1
#  sleep(5)  





