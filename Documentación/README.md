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

(FOTO EJERCICIO 3.7)

Los símbolos No Terminales serán aquellos caracteres en mayúsculas, y los Terminales vendrán dados en minúsculas y entre los caracteres ‘<’ y ’>’.

Cada línea será una regla de la gramática, y el fichero puede contener comentarios que comenzarán por el carácter ‘#’. Estos comentarios no serán tomados en cuenta al leerse el fichero.

El formato del fichero donde venga definida la cadena de entrada es más simple:

(FOTO CADENA ENTRADA)

Cada línea del fichero corresponde a un símbolo Terminal de la gramática. Todas las líneas del fichero forman la cadena de entrada.

Una vez leídos ambos ficheros, hay que establecer cómo serán tratados para guardar su información y así poder usarla.

La gramática será una lista de reglas, donde la primera regla será del símbolo inicial de la gramática. En estas reglas estarán presentes los símbolos No Terminales y Terminales de la gramática, los cuáles serán representados como cadenas de caracteres, identificados con alias de String:

=TROZO CODIGO NO TERMINAL TERMINAL=

Con estos nuevos alias, se define un nuevo tipo de dato Regla que contendrá la información necesaria de una regla de la gramática:


## Implementación en Prolog
Para quien no esté familiarizado con este lenguaje de programación declarativo, vamos a explicar los pasos que hemos seguido para realizar la implementación.

Primero necesitamos descargar su entorno, SWI-Prolog(10). Tiene una interfaz muy sencilla, donde podemos consultar nuestro código, editarlo en el propio entorno, etc. Nosotros usamos un editor de código externo, ya que el que trae swi deja que desear, usamos Visual Studio Code vinculado con este repositorio, lo cual recomendamos hacer, ya que es una herramienta muy cómoda y muy bien integrada en el editor.

En cuanto a la programación, la forma de plantear los problemas es diferente a la de un lenguaje imperativo, como puede ser Java, C++, etc. En este lenguaje no manejamos métodos, los llamamos predicados, para entender su funcionamiento podemos basarnos en la lógica proposicional, en la siguiente imagen vemos un ejemplo de ello:

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

