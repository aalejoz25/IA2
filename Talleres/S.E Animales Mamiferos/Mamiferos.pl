%Deduccion de algunos animales mamiferos

:- write("Digite 'ejecutar.' ").

ejecutar :- verifica(Animal), write("El animal es: "),write(Animal).

/*hechos y reglas*/

%se verifica el animal
verifica(onza):-onza,!.
verifica(tigre):-tigre,!.
verifica(cebra):-cebra,!.
verifica(jirafa):-jirafa,!.
verifica(desconocido).

/*Verificacion de las caracteristicas del animal*/

% Primero se verifica si el usuario no ha respondido anteriormente a la
% pregunta
onza:- comprobar(tiene_color_leonado),
       comprobar(tiene_manchas_oscuras).
tigre:- true.

%Se pregunta al usuario en caso de que no se haya
:- dynamic si/1, no/1.

preguntar(P):-
    write("El animal "), write(P), write("? "),nl,
    read(Respuesta),
    ((Respuesta==si)->(assert(si(P)));fail->(assert(no(P)))).

%Este bloque comprueba si la pregunta ya se agrego a la base de reglas
comprobar(Pregunta):-
    (si(Pregunta)->true).
comprobar(Pregunta):-
    (no(Pregunta)->false).
comprobar(Pregunta):- preguntar(Pregunta).






