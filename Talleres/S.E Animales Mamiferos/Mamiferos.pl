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

% Primero se comprueba si el usuario no ha respondido anteriormente a la
% pregunta
onza:- es_carnivoro,
       comprobar(tiene_color_leonado),
       comprobar(tiene_manchas_oscuras).
tigre:- true.


es_mamifero:-comprobar(tiene_pelo),
             comprobar(da_leche).
es_carnivoro:-es_mamifero,
              comprobar(come_carne).


% Se pregunta al usuario en caso de que no se haya agregado la pregunta
% a la base de reglas
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






