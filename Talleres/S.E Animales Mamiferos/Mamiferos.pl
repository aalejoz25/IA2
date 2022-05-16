%Deduccion de algunos animales mamiferos

:- write("Digite 'ejecutar.' ").

ejecutar :- verifica(Animal), write("El animal es: "),write(Animal),borrar.

/*hechos y reglas*/

%Predicados dinamicos
:- dynamic si/1, no/1.

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
       si(es_carnivoro),
       comprobar(tiene_color_leonado),
       si(tiene_color_leonado),
       comprobar(tiene_manchas_oscuras),
       si(tiene_manchas_oscuras).
tigre:- si(es_carnivoro),
        comprobar(tiene_franjas_negras),
        si(tiene_franjas_negras),
        comprobar(tiene_color_leonado),
        si(tiene_color_leonado).
cebra:- es_ungulado,
        si(es_ungulado),
        comprobar(tiene_franjas_negras),
        si(tiene_franjas_negras),
        comprobar(es_de_color_blanco),
        si(es_de_color_blanco).
jirafa:-si(es_ungulado),
        comprobar(tiene_manchas_oscuras),
        si(tiene_manchas_oscuras),
        comprobar(tiene_color_leonado),
        si(tiene_color_leonado),
        comprobar(tiene_patas_largas),
        si(tiene_patas_largas),
        comprobar(tiene_cuello_largo),
        si(tiene_cuello_largo).


es_mamifero:-comprobar(tiene_pelo),
             si(tiene_pelo),
             comprobar(da_leche),
             si(da_leche),
             assert(si(es_mamifero)),!.
es_mamifero:-assert(no(es_mamifero)).
es_ungulado:-si(es_mamifero),
             comprobar(tiene_pezuñas),
             si(tiene_pezuñas),
             assert(si(es_ungulado)),!.
es_ungulado:-si(es_mamifero),
             comprobar(rumia),
             si(rumia),
             assert(si(es_ungulado)),!.
es_ungulado:-assert(no(es_ungulado)).
es_carnivoro:-es_mamifero,
              si(es_mamifero),
              comprobar(come_carne),
              si(come_carne),
              assert(si(es_carnivoro)),!.
es_carnivoro:-si(es_mamifero),
              comprobar(tiene_dientes_agudos),
              si(tiene_dientes_agudos),
              comprobar(tiene_garras),
              si(tiene_garras),
              comprobar(tiene_ojos_que_miran_hacia_adelante),
              si(tiene_ojos_que_miran_hacia_adelante),
              assert(si(es_carnivoro)),!.
es_carnivoro:-assert(no(es_carnivoro)).


/* Se pregunta al usuario en caso de que no se haya agregado la pregunta a la base de reglas*/
%Este bloque comprueba si la pregunta ya se agrego a la base de reglas
comprobar(Pregunta):-
    (si(Pregunta)),!.
comprobar(Pregunta):-
    (no(Pregunta)),!.
comprobar(Pregunta):- preguntar(Pregunta).

% Se hace la pregunta en caso de que no este en la base de reglas y se
% añade a esta
preguntar(P):-
    write("El animal "), write(P), write("? "),nl,
    read(Respuesta),
    ((Respuesta==si)->(assert(si(P)));(Respuesta==no)->(assert(no(P)))).


/*Se borran todos los hechos en la base de reglas para la proxima consulta*/
borrar:-retract(si(_)),fail.
borrar:-retract(no(_)),fail.
borrar.








