%Deduccion de algunos animales mamiferos

:- write("Digite 'ejecutar.' ").

ejecutar :- verifica(Animal), write("El animal es: "),write(Animal).




%hechos y reglas
onza:- false.
tigre:- true.

%se verifica el animal
verifica(onza):-onza,!.
verifica(tigre):-tigre,!.
verifica(cebra):-cebra,!.
verifica(jirafa):-jirafa,!.
verifica(desconocido).

