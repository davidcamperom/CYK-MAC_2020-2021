#   Trabajo Práctico de Modelos Avanzados de Computación
:school: Universidad de Huelva  
:books: Curso 2020-2021    

##  Intención de la práctica
El objetivo de la práctica es realizar una pequeña aplicación, desarrollada en Haskell, la cual ponga en funcionamiento el algoritmo Cocke-Younger-Kasami usado para verificar si una cadena de entrada pertenece al lenguaje descrito por una gramática dada, en este caso, expresada en Forma Normal de Chomsky.

## Definición de tipos de datos
Este algoritmo se basa en el uso de una matriz donde las celdas contienen conjuntos de símbolos No terminales de la gramática. Estos símbolos son a su vez reconocidos por los símbolos No Terminales presentes en las celdas de niveles superiores. Si en la celda ubicada en el último nivel se encuentra el símbolo inicial de la gramática, quiere decir que a partir de ese símbolo se puede derivar toda la cadena de entrada y, por tanto, dicha cadena pertenece al lenguaje.

<img src="images/tabla_cyk_ejemplo.PNG" width="600">
    
Como se puede ver en este ejemplo de aplicación del algoritmo CYK, es necesario tener
almacenada la gramática y la cadena de entrada. Ambas serán introducidas al programa a
través de un fichero. El formato del fichero de gramática será el siguiente:

<img src="images/gramatica_ejemplo.PNG" width="500">

Los símbolos No Terminales serán aquellos caracteres en mayúsculas, y los Terminales vendrán dados en minúsculas y entre los caracteres ‘<’ y ’>’.

Cada línea será una regla de la gramática, y el fichero puede contener comentarios que comenzarán por el carácter ‘#’. Estos comentarios no serán tomados en cuenta al leerse el fichero.

El formato del fichero donde venga definida la cadena de entrada es más simple:

(FOTO CADENA ENTRADA)

Cada línea del fichero corresponde a un símbolo Terminal de la gramática. Todas las líneas del fichero forman la cadena de entrada.

Una vez leídos ambos ficheros, hay que establecer cómo serán tratados para guardar su información y así poder usarla.

La gramática será una lista de reglas, donde la primera regla será del símbolo inicial de la gramática. En estas reglas estarán presentes los símbolos No Terminales y Terminales de la gramática, los cuáles serán representados como cadenas de caracteres, identificados con alias de String:

=TROZO CODIGO NO TERMINAL TERMINAL=

Con estos nuevos alias, se define un nuevo tipo de dato Regla que contendrá la información necesaria de una regla de la gramática:

= TROZO CODIGO REGLA =

Este tipo dato Regla puede hacer referencia a:
- Una regla Terminal, en la que un símbolo No Terminal produce un símbolo Terminal: A ::= <a>.
- Una regla No Terminal, en la que un símbolo No Terminal produce dos símbolos No Terminales: A ::= B C.
- Una regla Nula, este será el tipo de regla empleado para las líneas en blanco de la gramática o aquellas reglas que tengan más de 2 símbolos en su parte derecha.

Definido el dato regla, podemos establecer que una gramática será una lista de reglas, y una entrada, una lista de símbolos Terminales:

= Trozo codigo gramatica entrada =

Declarados los tipos de datos, es preciso tomar el contenido del fichero leído y adaptarlo para guardar los datos en las estructuras definidas:
- Para el fichero de gramática, primero se dividirá el contenido en líneas, cada línea del fichero será un elemento candidato a ser regla. Estas líneas serán tratadas eliminando los posibles comentarios que puedan contener. Una vez eliminados, se trocea cada línea por las separaciones entre los símbolos (los espacios). Puede darse tres situaciones:
    - Que haya 3 elementos, entonces con esa línea se creará una regla Terminal, donde el       símbolo No Terminal será el primer elemento, y el símbolo Terminal, el último (el           símbolo intermedio se corresponde al símbolo de producción de la regla ‘::=’ y es           ignorado).
    - Que haya 4 elementos, entonces con esa línea se creará una regla No Terminal con el       primer elemento como símbolo No Terminal de la regla, y los dos últimos como símbolos       producidos.
    - Que sea otro número de elementos, entonces se creará una regla Nula.
- Para el fichero de cadena de entrada, se dividirá el contenido del fichero en líneas y cada línea será un símbolo Terminal. Previamente se eliminan los posibles espacios que pudiera haber en cada línea.

Por último, para poder aplicar el algoritmo, se definen los tipos necesarios para el uso de la tabla. Se considerará que una celda de la tabla será una lista de símbolos No Terminales, y, como se mencionó antes, las celdas de la tabla se encuentran por niveles. Estos niveles serán las diagonales de la tabla, siendo el nivel superior la diagonal con una única celda:

= trozo codigo celda diagonal =

## Implementación del algoritmo
Una vez definidas las estructuras donde se almacenará la información correspondiente a la gramática y a la cadena de entrada y cargados ambos desde sus respectivos ficheros, es momento de comenzar el análisis de la cadena para verificar si pertenece al lenguaje definido por la gramática o no.

Como se mencionó antes, el algoritmo CYK trabaja por niveles, donde en cada nivel, los símbolos No Terminales presentes reconocen a los símbolos de los niveles inferiores. Estos niveles serán las diagonales de la tabla que se irá rellenando.

Para la gramática:

(Foto de la gramatica)

Con la cadena de entrada: ( id ( id ( num ) ) ( id ) )
Se obtiene la siguiente tabla:

(Foto de la cadena)

Se pueden diferenciar dos tipos de diagonales:
- Primera diagonal: en ella aparecen los símbolos No Terminales de la gramática que tienen una regla con la que pueden producir el símbolo Terminal de la entrada que se encuentra al inicio de la columna.
- Diagonales internas: en ellas se encuentran los símbolos No Terminales que en sus reglas pueden producir el par de símbolos No Terminales, el primero a su misma altura en las celdas de las diagonales anteriores (la misma fila), y el otro en su misma columna, pero en las celdas de las diagonales inferiores. El contenido de la celda es el resultado de hacer este proceso tomando una a una todas las celdas en la misma fila y comparando con las celdas que se encuentren en la misma columna (primera en la fila con primera en la columna, segunda con segunda … ).
- Diagonal final: esta diagonal se obtiene del mismo modo que las demás diagonales internas, pero sólo tendrá una única celda.

Como se verá a continuación, la forma de obtener estas diagonales es diferente según sea la diagonal primera o una interna.

### Creación de la primera diagonal
Para la primera diagonal, dado que tiene el mismo número de elementos que símbolos Terminales hay en la cadena de entrada, se creará usando únicamente dicha información, además del uso de la Gramática para saber qué reglas se aplican.

(Foto primera diagonal)

Para esto, se han implementado dos funciones:

= trozo codigo funcion =

La primera de ellas, a partir de un símbolo Terminal, devuelve una lista de todos los símbolos No Terminales de la gramática que tengan una regla que produzcan dicho Terminal. Esta lista de No Terminales forma una celda de la tabla.

La segunda función realizará llamadas a la función anterior, profundizando de forma recursiva en la cadena de entrada. Cuando llega al final de la cadena, obtiene solo una celda, entonces, mediante la devolución por recursión, va creando la diagonal completa.

### Creación de las diagonales intermedias
Una vez creada la primera diagonal, se procede a la creación de todas las diagonales internas. El motivo por el que es necesario crear la primera diagonal antes es que estas diagonales intermedias requieren conocer los símbolos No Terminales presentes en las diagonales inferiores, puesto que los símbolos No Terminales que van a obtenerse serán aquellos que reconozcan los ya presentes.

(Foto diagonal intermedia)

A partir de los datos obtenidos de las diagonales anteriores, se comienza a crear la siguiente diagonal. Recursivamente, se profundiza en la diagonal nueva, hasta llegar al extremo inferior. Desde ahí, se construye la nueva diagonal, añadiendo en cada llamada recursiva una nueva celda a la diagonal, por tanto, la diagonal crece de abajo hacia arriba.

Como se puede apreciar, al momento de crearse una nueva celda, se deben de tomar de las diagonales anteriores una serie de celdas, las que se encuentran en la misma fila, y las que se encuentran en la misma columna. Para ello, se han implementado las siguientes funciones, que trabajan con un índice dado, que se corresponde con la posición que la celda va a tener en la nueva diagonal:

= trozo codigo =

Con ambas listas de celdas, se procede a tomar las celdas de dos en dos, para ver qué No Terminales producen los símbolos de estas celdas. Se comprobarán las celdas en este orden:

= trozo codigo =

La forma de realizar esta comprobación es mediante la siguiente función:

= trozo codigo =

Esta función recibe ambas listas y devuelve la nueva celda. Internamente, llama a la siguiente función, que será la que realice la comparación celda a celda:

= Trozo codigo =

Esta función recibe dos celdas, una de cada lista, y devuelve una celda con los posibles símbolos No Terminales que pueden reconocer los símbolos de las celdas.

Aunque devuelva una celda, en realidad esta celda es completada con los símbolos obtenidos tras analizar el resto de los pares de celdas.

Internamente, toma uno a uno (por recursión) los símbolos No Terminales de la primera celda y lo une con los posibles símbolos No Terminales que haya en la segunda celda, obteniendo así los símbolos No Terminales que producen a ambos.

Esta comprobación se realiza de forma similar a la de obtener los símbolos No Terminales que producen los símbolos Terminales, mediante la siguiente función:

= trozo codigo =

Esta función recibe dos símbolos No Terminales, el primero será de una celda situada en la misma fila, y el segundo será de la celda situada en la columna. Devolverá los símbolos No Terminales que produzcan a ambos, en el orden presentados a la función (primero el símbolo de la celda en la misma fila, y luego el símbolo de la celda de la misma columna).

La forma de realizar el recorrido de esta nueva diagonal es mediante la siguiente función:

= trozo codigo =

Esta función recibe todas las diagonales ya creadas y un número que significa el índice de la casilla que va a crear y que luego unirá al resto de casillas generadas por recursión. Recibirá como valor inicial de índice, el 0, dado por la función:

= trozo codigo =

Esta función se encarga de iniciar la recursión de la función anterior, llamándola con 0 como primer índice. Devuelve la diagonal generada por la función recursiva anterior.

Por último, para crearse la tabla, se utiliza la función:

= trozo codigo =

Esta función recibe la lista de las diagonales ya creadas, las diagonales inferiores, y devuelve una lista de diagonales compuesta por las que ha recibido más la nueva diagonal que acaba de crear. Esto se realizará de forma recursiva hasta que no pueda haber diagonales superiores, es decir, cuando se haya creado la última diagonal de longitud 1. En ese momento, habrá finalizado la creación de la tabla del algoritmo CYK.

Cabe destacar que, como puede verse en la definición de la función, recibe siempre una lista de las diagonales ya creadas. Como se mencionó antes, la primera diagonal se crea de forma diferente a las demás, por tanto, en la primera llamada recursiva, la lista de diagonales que recibirá será una lista formada por una única diagonal, que se corresponderá a la primera diagonal de la tabla. Esto se realiza en la función:

= trozo codigo =

Esta función recibe la gramática y la cadena de entrada, genera la primera diagonal de la tabla a partir de estos datos, y se la pasa a la función previa junto con la gramática que recibe. Finalmente devuelve la tabla completa.

### Interpretación de la tabla

Finalmente, obtenida la tabla mediante la creación de sus diagonales, es momento de ver si la cadena de entrada recibida inicialmente pertenece al lenguaje definido por la gramática o no. Para ello, tan sólo hay que comprobar si el símbolo inicial de la gramática se encuentra en la última celda de la tabla (esquina superior derecha).

Si el símbolo inicial se encuentra ahí, significa que desde ese símbolo se puede derivar toda la cadena de entrada y, por tanto, dicha cadena pertenece al lenguaje.

(iamgen tabla)

El símbolo inicial de la gramática será aquel que se encuentre en la primera regla de la gramática, en este caso, será el símbolo S, por la regla: S → num.

La forma de obtener dicho símbolo en el código es mediante la siguiente función:

= trozo codigo =

Que toma la primera regla de la gramática, sea Terminal o No Terminal, y devuelve el símbolo que aparezca en ella.

La función que realiza la comprobación final es la siguiente:

= trozo codigo = 

Recibe la gramática y la tabla generada, extrae el símbolo inicial de la gramática, accede a la última diagonal de la tabla y comprueba si el símbolo inicial se encuentra en la celda seleccionada.

## Visualización de los resultados


<p align="center">
<img src="imagenes/LogicaProposicional.jpg" width="300">
   
Donde vemos una serie de hechos relacionados con una serie de reglas y a partir de las distintas relaciones entre ellos podemos obtener conclusiones a nuestro problema. Prolog se basa en esta forma de "pensamiento", introducimos hechos o predicados y mediante una serie de relaciones nos dice si son verdaderas o falsas. Como estamos comprobando precisamente si dos o varios hechos tienen relación, no decimos que ejecutamos nuestro script, decimos que lo consultamos, por ello el último paso que realizaremos será clicar en la opción "Consult" de Swi-Prolog.

#### Predicados usados en el código
Inicialmente mostraremos por pantalla el mensaje con la pregunta inicial y una pequeña instrucción de cómo manejar el sistema experto.
```
inicio :-
    introduccion,
    reset_respuestas,
    busca_lenguaje(Lenguaje),
    describe(Lenguaje), nl.
```
El sistema irá mostrando las distintas opciones y un índice que hemos calculado para que el usuario solo escriba dicho número y el sistema internamente lo gestione. En cada "turno" se le hará una pregunta y se buscará el lenguaje que cumpla las condiciones, estas condiciones sabremos si se cumplen ya que vamos guardando las respuestas del usuario, en cierta forma es como ir descartando ramas del árbol que veíamos más arriba.
```
ask(Pregunta, Respuesta, Opciones) :-
    pregunta(Pregunta),
    respuestas(Opciones, 0),
    read(Index),
    parse(Index, Opciones, Solucion),
    asserta(progress(Pregunta, Solucion)),
    Solucion = Respuesta.
```
Cuando el sistema encuentra un código que cumpla todas las condiciones, lo muestra como solución y escribe en pantalla una descripción del lenguaje. Lo podemos ver más claro en la siguiente captura del programa:
<p align="center">
<img src="imagenes/Ejecucion.jpg" width="500">
   
## Diseño en Alexa
La siguiente fase en nuestro proyecto era integrar todo lo realizado hasta ahora en Alexa, lo cual nos trajo muchos quebraderos de cabeza. En cuanto a cómo integrar una API de prolog en Alexa, apenas existe información, por lo decir que no la hay. Encontramos una especie de tutorial donde un hombre realizada skill de Alexa la cual guardaba los facts que el hombre le decía y Alexa era capaz de memorizarlos, más tarde se le decía una relación entre estos facts y Alexa traducía todo a lenguaje Prolog, a partir de un parser de JSON a Prolog, y las relaciones funcionaban en prolog, el resultado era procesado y parseado a JSON y devuelto a Alexa con éxito.

Tras todo este embrollo, el resultado era una skill que entendía el lenguaje natural y era capaz de relacionar hechos y reglas, con back-end implementado en JSON y parseado a Prolog. En cierta medida era lo que buscábamos, pero nos quedamos a las puertas de implementar este back-end.

Uno de nuestro principales problemas era que necesitábamos crear un dominio propio, el cual Alexa usara como endpoint y al cual pudiera conectarse para hacer el intercambio de datos. Creamos uno en la página noip.com(11), y abrir un puerto por el cual poder establecer la conexión, lo cual no parecía difícil, pero desconocemos la causa por la que esto no funcionaba. Así que llegamos a un punto muerto en el desarrollo del proyecto.

<p align="center">
<img src="imagenes/FalloSkill.jpg" width="1000">

Decidimos informarnos de cómo funciona la web donde se desarrolla una skill de Alexa y que lenguajes deberíamos de dominar, por suerte para algunos, la web ha sufrido varias actualizaciones y actualmente se ha integrado en una sola web tonta el front-end, como el back-end. En principio el front-end funciona en JSON, pero la web nos facilita una forma gráfica de añadir slots e intents, por lo que no era necesario que dominásemos el lenguaje. En cuanto al front-end, existen 3 formas de realizarlo, a partir de un Node.js, con Python y por último custom y desde cero. El tutorial que mencionamos antes(4) lo realizaba con este último método, pero la parte de conexión con Alexa también corría por parte del propio desarrollador, así que investigamos si podría existir la forma de realizarlo con Node.js y parser Prolog a JavaScript.

<p align="center">
<img src="imagenes/CreacionSkill.jpg" width="800">

Encontramos una lista de unos tutoriales muy recomendables para entender el funcionamiento de esto(8) además de una masterclass del mismo autor(3).

Llegamos a la misma conclusión, ¿Cómo podemos hacer una conexión desde nuestra API de Prolog en nuestro dispositivo, hasta Alexa? por desgracia no encontramos una respuesta, así que pensamos una alternativa en HTML y encontramos otra lista de reproducción, donde se podía ver el proceso para realizar esto(9). Pero nos ocurrió el mismo problema, no conocemos una forma de crear un dominio y hacerlo funcionar.

Buscamos otra alternativa, PHP, donde encontramos un video un tipo muy simpático, que explicaba cómo realizar un juego de ajedrez, solo con peones, implementado en prolog, pero manejado desde una web escrita en PHP, un video bastante ilustrativo y con un enlace a su repositorio. Pero nos surgía el mismo problema de siempre, algo hacíamos mal a la hora de crear el dominio.
En un último intento, decidimos traducir el sistema experto de Prolog a JS o Python, para usar los métodos que hacen uso del dominio de la propia Amazon, que nos cede un espacio de 5Gb en su nube para el desarrollo de cualquier skill, como aún no teníamos conocimientos en estos lenguajes, buscamos ejemplos de alguna skill ya creada que fuese similar y encontramos un juego de Quiz, que en cierta forma se asemejaba a lo que buscábamos, pero justamente en lo que se diferenciaba era en la esencia del sistema experto, esta skill eran preguntas totalmente aleatorias. Llegamos a un punto en el que decidimos que lo que íbamos a hacer iba mucho más allá de los requisitos que se pedían en este proyecto.

Ya que cumplíamos con los requisitos necesarios para superar el proyecto, dejamos aparcada la idea de dar un paso más y llevarlo hasta Alexa, por la elevada saturación de carga de trabajo que estamos sufriendo en este 2020.
No sabemos si retomaremos este proyecto, pero hemos querido compartir nuestro desarrollo y experiencia y dejar en la comunidad un camino por el cual quien quisiera realizar algo similar pudiera tomar como referencia. Hemos dejado constancia de repositorios, videos y webs donde poder informarse.

## Implementación Alexa
¿Algún día...?

## Bibliografía
[1. Temario Modelos Avanzados de Computación](http://www.uhu.es/francisco.moreno/gii_mac/)  

