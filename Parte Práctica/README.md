#   Trabajo Práctico de Modelos Avanzados de Computación
:school: Universidad de Huelva  
:books: Curso 2020-2021    

##  Intención de la práctica
Con el desarrollo de esta práctica, pretendemos realizar un sistema experto implementado en el lenguaje declarativo PROLOG, una vez creado el sistema y sea totalmente funcional, desarrollaremos una skill de Alexa, la cual hará de mediadora entre el usuario y nuestro sistema. Alexa leerá las opciones del sistema y reconocerá la voz del usuario que dirá con su voz dirá la opción que desee, Alexa "dirá" internamente a prolog qué opción ha sido la seleccionada y la ejecutará para que nos devuelva otra salida.

Como sistema experto nos vamos a basar en un GitHub que hemos encontrado, pese a que contenía errores, nos hemos dispuesto a corregirlos, incluso pretendemos traducirlo, ya que apenas hemos encontrado información en español, aunque sabemos que es importante el uso de idiomas, queríamos que exista información en español, para que quien quiera realizar una práctica similar, no tenga que dedicar tiempo en entender el idioma y pueda centrarse al completo en el desarrollo.


## Diseño del Sistema Experto en Prolog
Para la implementación del sistema experto, hicimos uso del lenguaje declarativo "Prolog", pese a que en la asignatura nos enseñan a programar en este lenguaje, tuvimos que buscar información por otros medios, ya que los conocimientos que necesitamos iban un poco más allá del objetivo de la asignatura, teníamos entre manos un proyecto en cierta medida ambicioso.

Nos hemos basado casi por completo en este repositorio(1). Es muy recomendable, ya que nos sirvió para aprender cómo hacer un sistema experto en condiciones. En la página metalevel(2) pudimos hacernos una idea de qué camino tomar, por así decirlo existen 3 tipos de implementaciones y en función de lo que busquemos nos sirve más una u otra. Realmente no nos decantamos por uno en concreto, si no que hicimos una especie de mezcla que una vez acabado, no sabemos muy bien en qué categoría meter. Nos creamos una especie de árbol de decisión para tener más claro los caminos que estábamos generando y también para facilitar la fase de testeo, en la que encontramos bastantes fallos que nos habíamos dejado por el camino.


<img src="imagenes/Arbol.png" width="900">
    
Incluso hay que mencionar que conseguimos corregir un fallo que venía en el repositorio en el que nos estábamos basando. Como queríamos aportar un pequeño toque de originalidad y diferencia, decidimos traducirlo al español, que siempre es más cómodo para quien esté buscando información y no quiera perder tiempo con los pequeños atrasos que pueda hacer el trabajar con una lengua extranjera.

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
[1. GitHub Sistema Experto](https://github.com/linkyndy/expert-systems)  
[2. Metalevel Prolog](https://www.metalevel.at/prolog/expertsystems)  
[3. Cómo crear tu primera Skill en Alexa](https://www.youtube.com/watch?v=LAN-BJs6zrw)  
[4. Playing with Prolog](https://www.youtube.com/watch?v=ScrEe1vsPug&feature=emb_title)  
[5. GitHub Quiz](https://github.com/alexa/skill-sample-nodejs-quiz-game)  
[6. Llamar a Prolog desde PHP y tener un sistema experto en la web](https://www.youtube.com/watch?v=3sUj523cfPE)  
[7. GitHub Checkers Game Prolog y PHP](https://github.com/codermapuche/PHP-Prolog-HTML5-Checkers-Game)  
[8. Lista de reproducción cómo hacer una skill desde cero](https://www.youtube.com/watch?v=qv7ULb0TCN8&list=PL2KJmkHeYQTNzra-T2ayhV_84dHYCShAQ)  
[9. Prolog web FrameWork](https://www.youtube.com/watch?v=0fyE8Fuj3sg&list=PLo2Yjnxu38Q8VI6WVFLlTQOZ9LH9M4wyk)  
[10. Swi-Prolog](https://www.swi-prolog.org/)  
[11. NoIp.com](https://www.noip.com/)  
[12. Amazon Developers](https://developer.amazon.com/es/)
