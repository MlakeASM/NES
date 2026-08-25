# LECCIÓN 1
Vamos a ver la estructura básica de un cartucho e inicialización de la consola.


# Esquema básico del sistema
Imagen de https://forums.nesdev.org/viewtopic.php?t=20685
<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/diagrama.png?raw=true">


Para poder ejecutar un programa en nuestra NES tenemos que rellenar la PRG-ROM que es donde se almacena el código y la CHR-ROM que es donde se almacenan los gráficos.
Sin embargo, para agilizar el trámite y tenerlo todo organizado en un solo archivo, lo normal es generar un solo archivo siguiendo el formato iNES o NES2.0.
De esa forma podemos usar nuestro programa con un emulador o un flashcart tipo Everdrive en nuestra consola.<br/>

Los archivos .NES consisten en una cabecera (header) donde se detalla el contenido del cartucho seguido de la PRG-ROM y la CHR-ROM.

# Header
Imagen de https://www.nesdev.org/wiki/INES
<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/header.png?raw=true">

Para rellenar nuestra cabecera vamos a usar estos parámetros:

PRG_COUNT	= número de bloques de 16KB que va a tener nuestro programa. En principio podríamos usar hasta 2 (32KB)

CHR_COUNT	= número de bloques de 8KB que va a tener nuestro programa. Solo podemos usar 1 (8KB)

INES_REGION	= Sistema donde va a correr nuestro programa		;0 	= NTSC 60HZ    1 = PAL 50HZ

El resto de parámetros los veremos a medida que vayamos avanzando.

El código empezaría con algo así:

<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/headerDEV.png?raw=true">


# PRG-ROM

Como dijimos antes, aquí vamos a tener el código de nuestro programa. Tiene un tamaño máximo de 32KB y se encuentra mapeada en la CPU en el rango $8000-$FFFF.
Nuestro programa es muy pequeño así que con un bloque de 16KB vamos a tener de sobra, esto quiere decir que podemos usar el rango $8000-$BFFF o el $C000-$FFFF.

En nuestro caso vamos a elegir el primero, así podremos explicar otro detalle después.

<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/bloquePRG.png?raw=true">


La directriz .base inicia nuestro bloque y el $8000 es la posición donde empieza. A partir de ahí, comenzamos nuestro código (etiqueta "reset").



¿Qué diferencia hay entre usar un bloque u otro? 

En el caso de usar 1 solo bloque de 16KB, la NES automáticamente hace una "copia virtual" (mirroring) en los 16KB restantes. De tal forma que lo que tenemos en $8000-$BFFF
queda duplicado en $C000-$FFFF


¿Por qué ocurre eso? Porque la consola siempre espera 3 cosas al final de la PRG-ROM :


¿Dónde ir al llegar al VBlank (NMI)?

¿Dónde empieza nuestro programa?

¿Dónde ir en caso de una Interrupción externa (IRQ)?

<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/ints.png?raw=true">

Como no vamos a usar ni VBlank ni IRQ, las dejamos vacias (solo rti)
El inicio de nuestro programa se encuentra en "reset".

Esas direcciones/punteros tienen un sitio fijo para que la consola sepa localizarlas y no es otro que los ultimos 3 words de la PRG-ROM ($FFFA,$FFFC y $FFFE).
Por eso aunque solo usemos el rango $8000-$BFFF, su "copia" (mirror) tambien llega hasta $FFFF.

Esa zona se encuentra al final de nuestro bloque y la definimos de esta forma.

<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/vector.png?raw=true">

Con esto queda completo nuestra PRG-ROM


# CHR-ROM

Esta es mas fácil, simplemente tenemos que meter nuestras imagenes.


<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/chr.png?raw=true">


### Resumen
Nuestro archivo .NES se compone de:


HEADER


DECLARAR BLOQUE 16KB (.base $8000)

NUESTRO CÓDIGO

NMI e IRQ

VECTOR TABLE (.org $BFFA)

CARACTERES GFX


<img src="https://github.com/MlakeASM/NES/blob/main/Lecci%C3%B3n1/images/codigo.png?raw=true">




