# DRF1276G
Test módulo LoRa DRF1276G utilizando Micropython

El DRF1276G se controla utilizando un módulo ESP32 (ESP32 DEVKIT V1 DOIT).
Las conexiones se muestran a continuación:

<img width="1000" alt="Conexiones" src="https://github.com/Ferivas/DRF1276G/blob/main/DOCS/Conexiones.jpg">


Los pines se pueden cambiar en el módulo controller_esp32.
En este script se reciben datos por el puerto serial 2 del ESP32 (TX D17 y RX D13) que están marcados como 
El led de la tarjeta de desarrollo del ESP32 (D2) titila cuando el programa principal esta corriendo.

En el ejemplo no se conecto un display OLED (SSD1306) y por eso están comentadas las líneas que corresponden a las subrutinas del display.
