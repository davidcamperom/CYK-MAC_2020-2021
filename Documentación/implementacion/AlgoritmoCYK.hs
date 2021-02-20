-- Proyect Final Modelos Avanzados de Computacion
-- Algoritmo CYK

import System.IO 
import Data.Char 
import Data.List 
import System.Directory



-- ======================================================================================
--      DEFINICION DE ALIAS Y DATOS
-- ======================================================================================

-- FUNCION: Creacion de los tipos NoTerminal y Terminal
--
-- DESCRIPCION: Para representar los simbolos no terminales y terminales de una regla
--
type NoTerminal = String
type Terminal = String

-- FUNCION: Creacion de los tipos ReglaN, ReglaT y ReglaNula
--
-- DESCRIPCION: Para representar las reglas, que pueden ser del tipo
--      No Terminal --> A ::= B C
--         Terminal --> A ::= <a>
--             Nula --> Linea en blanco
data Regla = ReglaN NoTerminal NoTerminal NoTerminal
            | ReglaT NoTerminal Terminal
            | ReglaNula
            deriving(Eq,Show)

-- FUNCION: Creacion de los tipos Gramatica y Entrada
--
-- DESCRIPCION: Gramatica servira como lista de reglas y Entrada servira como lista
--              de terminales
type Gramatica = [Regla]
type Entrada = [Terminal]

-- FUNCION: Creacion de los tipos Celda y diagonal
--
-- DESCRIPCION: Celda servira como lista de no terminales y Diagonal como lista de celdas
type Celda = [NoTerminal]
type Diagonal = [Celda]

-- FUNCION: Creacion del dato Resultado 
--
-- DESCRIPCION: Dos construcciones posibles, que sea correcta o incorrecta
data Resultado = Correcta
                | Incorrecta

-- FUNCION: Definicion de la estancia Show
--
-- DESCRIPCION: Muestra el dato Resultado
instance Show Resultado where
    show Correcta = "Correcta\n"
    show Incorrecta = "Incorrecta\n"






-- ================================================================================================
--      DEFINICION DE FUNCIONES
--      LECTURA DE LA GRAMATICA
-- ================================================================================================

-- FUNCION: quitarComentarios
--
-- DESCRIPCION: Recibe una linea del fichero donde se define la gramatica como un String
--      Obtiene todas las palabras que contiene diche linea y toma aquellas que se 
--      encuentren antes de la palabra que comience por el caracter #
--      Las palabras no descartadas se unen de nuevo en un String
quitarComentarios :: String -> String
quitarComentarios linea = unwords (takeWhile (\(c:resto) -> c /= '#') (words linea))


-- FUNCION: creaRegla
--
-- DESCRIPCION: Recibe una lista de String que se corresponde  con las palabras que hay
--      en una linea del fichero de gramatica, segun la dimension se crea:
--      - Regla Terminal
--      - Regla No Terminal
--      - Regla Nula
creaRegla :: [String] -> Regla
creaRegla linea
    | length linea == 3 = ReglaT (linea!!0) (linea!!2)
    | length linea == 4 = ReglaN (linea!!0) (linea!!2) (linea!!3)
    | otherwise = ReglaNula


-- Funcion: leeGramatica
--
-- Descripcion: Recibe una lista de String que corresponden a las lineas del fichero 
--      de gramatica. Crea la regla correspondiente a los simbolos presentes en la 
--      primera linea
--      Si hay más de una regla, esta nueva regla sera la cabeza de la lista de reglas
--      obtenida por recursion
leeGramatica :: [String] -> [Regla]
leeGramatica [unaSola] = [creaRegla (words (quitarComentarios unaSola))]
leeGramatica (linea:resto) = 
    let r = creaRegla (words (quitarComentarios linea))
    in r:leeGramatica(resto)


-- FUNCION: quitarElemento
--
-- DESCRIPCION: Recibe una lista y un elemento
--      Devuelve una nueva lista con los elementos de la lista pasada sin el elemento
quitarElemento :: (Eq a) => [a] -> a -> [a]
quitarElemento [] _ = []
quitarElemento (x:xs) e 
    | x == e = quitarElemento xs e
    | otherwise = x:( quitarElemento xs e )


-- FUNCION: generaGramatica
--
-- DESCRIPCION: Recibe una lista con las lineas del fichero de gramatica
--      Devuelve la gramatica compuesta por las reglas definidas en el fichero sin reglas 
--      nulas
generaGramatica :: [String] -> Gramatica
generaGramatica lineas = quitarElemento (leeGramatica lineas) ReglaNula






-- ================================================================================================
--      DEFINICION DE FUNCIONES
--      ALGORITMO CYK
-- ================================================================================================

-- FUNCION: reglasReconoceTerminal
--
-- DESCRIPCION: dado un simbolo Terminal y una gramatica, devuelve una celda compuesta 
--      por todos los simbolos No Terminales de la gramatica que producen el simbolo 
--      terminal dado
reglasReconoceTerminal :: Terminal -> Gramatica -> Celda
reglasReconoceTerminal _ [] = []
reglasReconoceTerminal t ((ReglaT s tt):resto)
    | t == tt = s:(reglasReconoceTerminal t resto)
    | otherwise = reglasReconoceTerminal t resto
reglasReconoceTerminal t ((ReglaN _ _ _):resto) = reglasReconoceTerminal t resto


-- FUNCION: reglasReconoceParNoTerminal
--
-- DESCRIPCION: Dados dos simbolos No Terminales (a, b) y una gramatica, devuelve una
--      celda compuesta por todos los simbolos No Terminales de la gramatica que 
--      producen ambos no terminales en el orden definido, (a, b), no válido (b, a)
reglasReconoceParNoTerminal :: NoTerminal -> NoTerminal -> Gramatica -> Celda
reglasReconoceParNoTerminal _ _ [] = []
reglasReconoceParNoTerminal a b ((ReglaN s aa bb):resto)
    | a == aa && b == bb = s:(reglasReconoceParNoTerminal a b resto)
    | otherwise = reglasReconoceParNoTerminal a b resto
reglasReconoceParNoTerminal a b ((ReglaT _ _):resto) = reglasReconoceParNoTerminal a b resto


-- FUNCION: reglasReconoceNoTerminal
--
-- DESCRIPCION: Dado un simbolo No Terminal, una celda y una gramatica, devuelve la 
--      celda compuesta por todos los símbolos No Terminales que producen el par de
--      no terminales formado por el símbolo pasado seguido de cada uno presente en
--      la celda dada
reglasReconoceNoTerminal :: NoTerminal -> Celda -> Gramatica -> Celda
reglasReconoceNoTerminal _ [] _ = []
reglasReconoceNoTerminal _ _ [] = []
reglasReconoceNoTerminal a (b:resto) g = (reglasReconoceParNoTerminal a b g) ++ (reglasReconoceNoTerminal a resto g)


-- FUNCION: reglasReconoceNoTerminales
--
-- DESCRIPCION: Recibe dos celdas y una gramatica. Toma el primer No Terminal de la 
--      primera celda y obtiene todos los No Terminales que su regla produce este 
--      No Terminal seguido de cada uno de los No Terminales de la otra celda
--      Estos No Terminales los concatena a los que obtiene por recursión con los 
--      siguiente No Terminales de la primera celda
reglasReconoceNoTerminales :: Celda -> Celda -> Gramatica -> Celda
reglasReconoceNoTerminales [] _ _ = []
reglasReconoceNoTerminales _ [] _ = []
reglasReconoceNoTerminales (a:resto) otros g = (reglasReconoceNoTerminal a otros g) ++ (reglasReconoceNoTerminales resto otros g)


-- FUNCION: quitarDuplicados
--
-- DESCRIPCION: Elimina la aparicion de más de un mismo No Terminal por celda
quitarDuplicados :: Celda -> Celda
quitarDuplicados [] = []
quitarDuplicados (e:resto) = e : quitarDuplicados (filter (/= e) resto)


-- FUNCION: reglasReconoceDosCasillas
--
-- DESCRIPCION: Devuelve los No Terminales que producen las reglas que tienen un No
--      Terminal de la primera celda y el otro No Terminal en la segunda celda. Los 
--      No Terminales no se repiten
reglasReconoceDosCasillas :: Celda -> Celda -> Gramatica -> Celda
reglasReconoceDosCasillas l1 l2 g = quitarDuplicados (reglasReconoceNoTerminales l1 l2 g)


-- FUNCION: rellenaPrimerDiagonal
--
-- DESCRIPCION: Recibe la lista de simbolos Terminales que constuyen la Entrada, y
--      la gramatica
--      Devuelve la primera diagonal de la tabla, donde cada celda contiene los No
--      Terminales que producen los simbolos Terminales pasados
rellenaPrimeraDiagonal :: Entrada -> Gramatica -> Diagonal
rellenaPrimeraDiagonal [t] g = [reglasReconoceTerminal t g]
rellenaPrimeraDiagonal (t:resto) g = [reglasReconoceTerminal t g] ++ (rellenaPrimeraDiagonal resto g)


-- FUNCION: fila
--
-- DESCRIPCION: Obtiene la lista de celdas que estan en una fila n
fila :: [Diagonal] -> Int -> [Celda]
fila [d] n = [(d!!n)]
fila (d:resto) n = (d!!n):(fila resto n)


-- FUNCION: columna
--
-- DESCRIPCION: Obtiene la lista de celtas que se encuentran en la misma columna, 
--      a partir de la posicion n
columna :: [Diagonal] -> Int -> [Celda]
columna [d] n = [d !! (n + 1)]
columna diagonales n =
    let d = last diagonales
        resto = init diagonales
    in ( d !! (n + 1)) : (columna resto (n + 1))


-- FUNCION: recorreParesDeCeldas
--
-- DESCRIPCION: Recibe dos listas de celdas y una gramatica
--      Tomara la primera celda de cada lista y obtendra los símbolos No Terminales que 
--      producen los simbolos que se encuentren en dichas celdas. Los demás simbolos 
--      No Terminales que reconocen el resto de las celdas sera obtenido a traves
--      de recursion
recorreParesDeCeldas :: [Celda] -> [Celda] -> Gramatica -> Celda
recorreParesDeCeldas [] [] _ = []
recorreParesDeCeldas (f:restoF) (c:restoC) g = quitarDuplicados ((reglasReconoceDosCasillas f c g) ++ (recorreParesDeCeldas restoF restoC g))


-- FUNCION: recorreDiagonal
--
-- DESCRIPCION: Recibe una lista de diagonales ya creadas, un indice y una gramatica
--      Devuelve una nueva diagonal
--      Obtiene la lista de celdas que se encuentran en la misma fila n
--      Obtiene la lista de celdas que se encuentran en la misma columna a partir de n
--      Crea la celda actual mediante los símbolos No Terminales que reconocen estas 
--      listas de celdas. Por recursion continua creando la nueva diagonal, insertando
--      la celda actual al principio de la lista
recorreDiagonal :: [Diagonal] -> Int -> Gramatica -> Diagonal
recorreDiagonal diagonales n g
    | n > 0 = (recorreParesDeCeldas f c g) : (recorreDiagonal diagonales (n - 1) g)
    | otherwise = [recorreParesDeCeldas f c g]
    where f = fila diagonales n
          c = columna diagonales n


-- FUNCION: creaDiagonal
--
-- DESCRIPCION: Recibe una lista de diagonales ya creadas y una gramatica
--      Devuelve una nueva diagonal con dimension 1 menor que la ultima diagonal 
--      que ha recibido
creaDiagonal :: [Diagonal] -> Gramatica -> Diagonal
creaDiagonal diagonales g =
    let n = ((length (diagonales !! 0)) - (length diagonales)) - 1
    in recorreDiagonal diagonales n g


-- FUNCION: creaDiagonales
--
-- DESCRIPCION: Recibe una lista de diagonales ya creadas y una gramatica
--      Devuelve otra lista de diagonales compuesta de las que ha recibido mas una 
--      nueva que se acaba de crear, de longitud 1 menos
creaDiagonales :: [Diagonal] -> Gramatica -> [Diagonal]
creaDiagonales diagonales g 
    | length d > 1 = creaDiagonales (diagonales ++ [d]) g
    | otherwise = diagonales ++ [d]
    where d = reverse (creaDiagonal diagonales g)


-- FUNCION: primerSimbolo
--
-- DESCRIPCION: Dada una gramatica, devuelve el simbolo No Terminal de la primera regla
--      Sera el simbolo inicial de la gramatica
primerSimbolo :: Gramatica -> NoTerminal
primerSimbolo ((ReglaT s _):_) = s
primerSimbolo ((ReglaN s _ _):_) = s


-- FUNCION: algoritmoCYK_CreaTabla
--
-- DESCRIPCION: Recibe una gramatica y una Entrada
--      Devuelve una lista de diagonales
algoritmoCYK_CreaTabla :: Gramatica -> Entrada -> [Diagonal]
algoritmoCYK_CreaTabla g e = creaDiagonales [rellenaPrimeraDiagonal e g] g


-- FUNCION: algoritmoCYK
--
-- DESCRIPCION: Recibe una gramatica y una lista de diagonales
--      Devuelve un Resultado que puede ser:
--      - Correcta si el símbolo incicial de la gramatica aparece en la ultima diagonal
--      - Incorrecta si el simbolo inicial no esta
algoritmoCYK :: Gramatica -> [Diagonal] -> Resultado
algoritmoCYK g tabla =
    let sInicial = primerSimbolo g
        n = (length tabla) - 1
    in case elem sInicial ((tabla !! n) !! 0) of True -> Correcta
                                                 False -> Incorrecta





-- ================================================================================================
--      DEFINICION DE FUNCIONES
--      REPRESENTAR GRAFICAMENTE LA TABLA
-- ================================================================================================                                           


-- FUNCION: creaFila
--
-- DESCRIPCION: Recibe una lista de diagonales y un indice n
--      Devuelve las celdas ubicadas en el indice n de cada diagonal en una unica lista
creaFila :: [Diagonal] -> Int -> [Celda]
creaFila [] _ = []
creaFila (d:resto) n 
    | (length d) < (n + 1) = []
    | otherwise = (d !! n) : (creaFila resto n)


-- FUNCION: creaFilas
--
-- DESCRIPCION: Recibe una lista de diagonales y un indice n
--      Devuelve una lista de lista de celdas (tabla de celdas) donde cada lista de celdas
--      corresponde a las celdas ubicadas en el indice n de las diagonales
creaFilas :: [Diagonal] -> Int -> [[Celda]]
creaFilas [] _ = []
creaFilas diagonales n 
    | length(diagonales) == n = []
    | otherwise = filaAct : filasSiguientes
    where filaAct = creaFila diagonales n
          filasSiguientes = creaFilas diagonales (n + 1)


-- FUNCION: organizaTabla
--
-- DESCRIPCION: Recibe una lista de diagonales
--      Devuelve una tabla de celdas (lista de lista de celdas) donde cada fila corresponde
--      a las celdas que estan a la misma profundidad/altura en las diagonales
organizaTabla :: [Diagonal] -> [[Celda]]
organizaTabla diagonales = creaFilas diagonales 0


-- FUNCION: verFila
--
-- DESCRIPCION: Recibe una lista de celdas (una fila de la tabla) 
--      Muestra graficamente la fila, con una separación entre celdas que varía segun el 
--      numero de simbolos No Terminales que haya en cada celda. Si hay más de 3 
--      simbolos No Terminales por celda, visualmente dejara de estar alineado. Lo mismo 
--      si los simbolos No Terminales son de mas de un caracter
verFila :: [Celda] -> IO()
verFila [] = putStrLn ""
verFila (c:resto) = do
    let n = length c
    let n2 = if n > 0 then n * 3 + (n - 1) + 2 else 2
    let espaciado = replicate (14 - n2) ' '
    putStr ((show c) ++ espaciado)
    verFila resto


-- FUNCION: verTabla
--
-- DESCRIPCION: Recibe una lista de lista de celdas (la tabla de celdas) 
--      Muestra graficamente la fila actual, con una separacion inicial de espacios que 
--      conforme mas profunda sea la recursion, mas separada estara del comienzo de  la 
--      pantalla. Si hay mas de 3 simbolos No Terminales por celda, visualmente dejara 
--      de estar alineado. Lo mismo si los simbolos No Terminales son de mas de un caracter
verTabla :: [[Celda]] -> Int -> IO()
verTabla [] _ = putStrLn ""
verTabla (f:resto) n  = do
    putStr (replicate (n * 14) ' ')
    verFila f
    verTabla resto (n + 1)





-- ================================================================================================
--      MAIN       
-- ================================================================================================ 


-- FUNCION: main
--
-- DESCRIPCION: Solicita por teclado el nombre del fichero donse se encuentra la gramatica
--      y la Entrada
--      Convierte la gramatica a una lista de Reglas
--      Convierte la entrada a una lista de Terminales
--      Obtiene la tabla del algoritmo CYK
--      A partir de la tabla generada, verifica si la entrada pertenece al lenguaje de 
--      la gramatica. Representa por pantalla la tabla generada
main = do
    putStrLn "Introduce el nombre del fichero que contiene la gramática: "
    nombreGramatica <- getLine
    putStrLn "Introduce el nombre del fichero que contiene la entrada: "
    nombreEntrada<- getLine

    handleG <- openFile nombreGramatica ReadMode
    handleE <- openFile nombreEntrada ReadMode

    contenidoG <- hGetContents handleG   
    contenidoE <- hGetContents handleE

    let gramatica = generaGramatica (lines contenidoG)
    let entrada = map (\x -> quitarElemento x ' ') (lines contenidoE)

    let tabla = algoritmoCYK_CreaTabla gramatica entrada

    putStr "Cadena de entrada = "
    putStrLn (unwords (entrada))

    putStr "RESULTADO = "
    putStr (show (algoritmoCYK gramatica tabla))

    putStrLn "Tabla obtenida al aplicar el algoritmo CYK:"
    verTabla (organizaTabla tabla) 0

    hClose handleG
    hClose handleE