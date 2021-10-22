# Wifi-Attack
Es una herramienta escrita en bash y python cuyo objetivo realiza diversos ataques a redes wifi que son los siguientes: <br>
- Ataque Handshake
- Ataque PKMID
- EvilTwin                                                                                                                                                                       
## Instalacion 
```
git clone https://github.com/ErickBuster/Wifi-Attack.git
cd Wifi-Attack 
chmod +x wifi-Atack.sh
```
### Modo de Uso
```
./wifi-Atack.sh!
```
![Menu](https://user-images.githubusercontent.com/91999629/138252631-1ac671e4-ec54-4ff7-8614-9fa9d7982047.jpg)

## Ataque Handshake
### Ataque de fuerza bruta
Para este ataque hace uso de la suit de Aircrack el cual escanea las redes disponibles y posteriormente poder obtener una Handshake desautenticando a los usuarios de la red<br>
Para este primer caso usaremos un diccionario propio donde se puede especificar desde una inicio con el parametro ```-w <diccionario>``` o dentro de la aplicacion al obtener una **Handshake**<br>
comando a usar:
```
./wifi-Attack.sh -m Hanshake -i wlan0
./wifi-Attack.sh -m Hanshake -i wlan0 -w wordlist
```
![Hanshake](https://user-images.githubusercontent.com/91999629/138369452-3f2dd2df-c8f4-4bab-9a31-55cbf58ed7e3.gif)

### Ataque con EvilTwin (gemelo malvado)
Para este caso al momento de obtener una Handshake del punto de acceso, si la contraseña llegara a ser robusta, podemos crear punto de acceso falso con el mismo nombre y canal del punto de acceso original.<br>Para que el usuario al conectarse a la red, le pedira la contraseña de su red, mostrara en pantalla las contraseñas ingresadas y comprobara de forma trasera la contraseña con en handshake obtenido<br>Al momento de ingresar la contraseña obtenida correctamente, lo guardara en una archivo con un nombre identificador ***PASS_FOUND_ESSID***
> Hay que tener en cuenta que para el ataque EvilTwin necesitamos tener una conexion a internet desde una interfaz de red eth0 o alguna otra, (posteriormente se añadiera para que funcione sin una conexion a internet previa)

![Handshake-and-EvilTwin](https://user-images.githubusercontent.com/91999629/138369314-f48f9a0a-755f-4bd5-b127-ad83752cf078.gif)

Lo que la victima veria en su red wifi seria lo siguiente:

![Evil-Mobile](https://user-images.githubusercontent.com/91999629/138371103-13975000-cf53-4b75-957d-7661fab45c99.gif)


## Ataque PKMID
Este ataque describe una tecnica para descifrar constraseñas WPA PSK "clave precompartida" (Pre-Shared Key)<br>
El cual no se requiere algun ataque de desautenticacion, ya que el atacante se comunica directamente con el AP (Se conoce como ***ataque sin cliente***)
para este ataque se realiza de la siguiente manera:
```
./wifi-Attack.sh -m PKMID -i wlan0
./wifi-Attack.sh -m PKMID -i wlan0 -w wordlist
```
![PKMID](https://user-images.githubusercontent.com/91999629/138373133-528801e9-4c8c-42c2-a6fd-41c106e61b8e.gif)
 
 Obtendra un archivo cap y con la utileria **hcxpcaptool** obtendra los hashes de la captura pcap para asi descifrarlo con **Hashcat** para asi descifrar la contraseña de la red
 
 
## EvilTwin
Este tipo de ataque genera de fornma atomatizada un punto de Acceso falso (Fake AP), en el cual dispone de varias plantillas<br>
Cabe destacar que podemos agregar mas plantillas personalizadas en la carpeta websites, agregamos la carpeta con el contenido de la plantilla personalizada<br>
O tambien puedes descargar mas plantillas personalizadas en mi github [Plantillas](https://github.com/ErickBuster/websites)
> Hay que tener en cuenta que para el ataque EvilTwin necesitamos tener una conexion a internet desde una interfaz de red eth0 o alguna otra, (posteriormente se añadiera para que funcione sin una conexion a internet previa)

![EvilTwin](https://user-images.githubusercontent.com/91999629/138378013-d584b3ec-ff38-4b17-a0f6-1fe225015941.gif)

Lo que la victima observaria al conectarse seria lo siguiente

![EvilTwin-mobile](https://user-images.githubusercontent.com/91999629/138378405-b9a40007-7156-4466-ac71-7b6b02973672.gif)

## Notas adicionales
- El programa por defecto renombra la interfaz como ```Wlan0``` esto puedes editarlo en caso de que tengas algun conflicto con otra tarjeta conectada en el archivo ```settings/interface_setting```
