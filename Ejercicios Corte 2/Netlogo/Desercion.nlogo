;Conexion a la base de datos
;======================================================================================
extensions [sql]
breed [ students student ]
breed [ subjects subjectU ]

to conn-bd
 sql:configure "defaultconnection" [["brand" "PostgreSQL"] ["host" "localhost"] ["port" 5432] ["database" "Desercion"]["jdbcurl" "jdbc:postgresql://127.0.0.1:5432/postgres"] ["driver" "org.postgresql.Driver"] ["user" "postgres"]["password" "mcc123"]
["autodisconnect" "on"]]
 sql:configure "connectionpool" [["timeout" 5000]]
 sql:autocommit-on
end

to setup-bd
 sql:exec-update "delete from martha.estudiante_materia" []
 sql:exec-update "delete from martha.reg_semestral" []
 print sql:current-database
end


turtles-own [
 my-schedule
 grades
 class]
students-own [
 CodStudent ;Código del estudiante
 YearIn ;Año de ingreso
 PeriodIn ;Periodo de ingreso
 Gender ;Genero
 Age ;Edad de ingreso
 Stratum ;Estrato del estudiante
 Birthplace ;Lugar de nacimiento
 TypeRegister ;Tipo de inscripción
 StatusA ;Estado académico actual del estudiante (Activo, Enprueba, Desertor, TerminoM, Graduado)
 ScoreIcfes ;Puntaje del examen de estado, requisito para ingreso a la universidad equivalente de 0 a 100 pts
 AccumAverage ;Promedio acumulad
 AverageSem ;Promedio semestre
 NumPruebas ;Número de pruebas en las que ha incurrido el estudiante
 StatePrueba ;Estado de la prueba académica
 SemesterE ;Materia aprobada del semestre mas bajo acorde al curriculum :: Posición del estudiante en la malla
 CurrentPeriod ;Periodo actual del estudiante 1 0 2
 CurrentYear ;Año actual
 approvedSubjects ;Materias aprobadas
 lostSubjects ;Materias perdidas lista compuesta de la abreviatura y estado -1 -2 y -3
 pendingSubjects ;Materias que nunca ha cursado
 enrolledSubjects ;Materias cursadas en el semestre
 repetitionIndex ;índice de repitencia
 backwardnessIndex;índice de Atraso
 permanenceIndex ;índice de permanencia
 nivelIndex ;índice de nivelación
 efficiencyIndex ;índice de eficiencia
 numMatriculas ;Número de matrículas
 creditsDisp ;Máximo de créditos semestre a semestre -- mín 15 normal 18 max 21
 TApproved ;Número total de materias aprobadas
 TLost ;Número total de materias perdidas
 TEnrolled ;Número total de materias vistas
 AcadPerformance ;Rendimiento académico del estudiante
 AcademicSupport ;Apoyo académico
 foodAssistance ;Apoyo alimentario
]
subjects-own[
 name ;Name of the subject
 semester ;Different semesters of the student (1 - 10)
 credits ;Número de créditos de la materia
 dificult ;Probabilidad de perdida de la materia
]


globals [
 coord_inX ;Coordenada inicial en X
 coord_inY ;Coordenada inicial en Y
 stopProgram ;Variable booleana que permite identificar cuando debe detenerse la simulación
 curriculum ;Carga el curriculum del proyecto seleccionado
 numproyecto ;Proyecto seleccionado desde la interfaz
 limiteMatriculas;Número límite de matriculas que puede tener un estudiante
 selecStudents ;Arreglo donde se cargan los estudiantes de la base de datos
 TotPaAverage ;Variable que guarda el total de prueba académica por promedio
 totPaThree ;Variable que guarda el total de prueba académica por repetir tres asignaturas
 totPaThird ;Variable que guarda el total de prueba académica por repetir una materia 3 veces
 numCreditsPlan ;Total de créditos del plan de estudios
 totStudentPCE ;Total de estudiantes que pierden calidad
 totTerminoM ;Total de estudiantes que terminaron materias
 totStudentE ;Total de estudiantes egresados
 contador ;
 totale-M totale-F ; total de los estudiantes por estrato
 totali-M totali-F ; total de los estudiantes por estrato
 totalp-M totalp-F ; total de los estudiantes por estrato
 ganapierdeeM ganapierdeeF ; total ganan o pierden por estrato
 ganapierdeiM ganapierdeiF ; total ganan o pierden por inscripción
 ganapierdepM ganapierdepF ; total ganan o pierden por estrato
 fbayese ; factor de probabilidad de perder y ganar por género y estrato aplicando Bayes
 fbayesi ; factor de probabilidad de perder y ganar por tipo inscripción
 fbayesap ; factor de probabilidad de perder y ganar por tipo apoyo alimentario
 limitem ; nota limite masculino
 totStudentC ; Total estudiantes por curso
 totStudentG ; Total estudiantes graduados
 totsuperaMat ; Total estudiantes que superan límite matriculas
 semestralStudentGrades ; Calificaciones de los estudiantes
]

;MAIN PROCEDURE
;======================================================================================
to setup
 clear-all
 setup-globals
 setup-world
 reset-ticks
end
to setup-globals
 clear-patches
 set-default-shape subjects "circle"
 set-default-shape students "person"
 set coord_inX -18
 set coord_inY 20
 set stopProgram false
 set TotPaAverage 0
 set totPaThree 0
 set totPaThird 0
 ifelse activar-control-matriculas
 [ set limiteMatriculas 25]
 [set limiteMatriculas 15]
 set selecStudents []
end

to setup-world
 ;conn-bd
 ;setup-bd
 setup-curriculum
 calCreditsPlan
 setup-subjects
 loadStudents
 setup-students
end



;==========================================================================================
; Configuración de la malla curricular
;==========================================================================================
to setup-curriculum
 print (word "proyecto seleccionado "proyectoIng)
 
 let choice proyectoIng
 if
   choice = "ING DE SISTEMAS" [
     set numproyecto 1
     ]
 if
   choice = "ING CATASTRAL" [
     set numproyecto 2
      ]
 if
   choice = "ING ELECTRICA" [
     set numproyecto 3
      ]
 if
   choice = "ING ELECTRONICA" [
     set numproyecto 4
      ]
 if
   choice = "ING INDUSTRIAL" [
     set numproyecto 5
      ]

 print (word "número proyecto " numproyecto)
 set curriculum []
 loadCurriculum
 print (word "curriculum actual " curriculum)
end
;==========================================================================================

;===========================================================================================
;====== Carga el curriculum del proyecto seleccionado en la interfaz
;==========================================================================================
to loadCurriculum 
 let msemestre []
 ;[set msemestre []
   if
   numproyecto = 1 [
     set msemestre (sentence msemestre (list ["Cal_Dif" 4 70 1]["Pro_Bas" 3 25 2]["Sem_Ing" 1 20 3]["Log" 3 40 4]["Cat_FJC" 1 15 5]["Prod_Comp_Tex" 2 15 6]["Cat_Dem_Ciu" 1 15 7]["Cat_Cont" 1 10 8] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Fis_1" 3 65 9]["Cal_Int" 3 70 10]["Alg_Lin" 3 60 11]["POO" 3 40 12]["Et_Bio" 2 20 13]["Seg_Leng_1" 2 25 14]["El_Ex_1" 2 10 15] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Fis_2" 4 70 16]["Cal_Mult" 3 70 17]["Ec_Dif" 3 70 18]["Teo_Sis" 2 30 19]["Prog_Ava" 3 50 20]["Elec_Cienc_Bas" 1 30 21]["Gr_Trab_1" 1 10 22]["Seg_Leng_2" 2 25 23] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Mat_Esp" 3 85 24]["Mod_Prog_1" 3 55 25]["An_Sis" 2 25 26]["Mat_Dis" 3 40 27]["Met_Num" 1 35 28]["Fund_BD" 2 45 29]["Seg_Leng_3" 2 25 30]["El_Ex_2" 2 10 31] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Fis_3" 3 70 32]["Arq_Comp_Lab" 2 35 33]["Mod_Prog_2" 3 55 34]["Cie_Comp_1" 3 50 35]["IO1" 3 60 36]["Prob" 3 40 37]["Gr_Trab_2" 1 10 38] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Cib_1" 2 55 39]["Redes_1" 2 45 40]["Cie_Comp_2" 3 45 42]["IO2" 3 55 43]["Est" 3 55 44]["Hist_Cul_Col" 2 30 45]["Elec_Hum" 1 20 46]["El_Ex_3" 2 10 47] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Econ" 2 20 48]["Cib_2" 2 55 49]["Redes_2" 3 50 50]["IO3" 2 45 51]["FIS" 3 45 52]["FIA" 1 25 53]["El_Cie_Comp" 1 35 54]["Gr_Trab_3" 1 10 55] ["Gr_Inv_1" 3 25 56]))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["Ingeco" 2 45 57]["Cib_3" 2 50 58]["Arq_Y_Patr" 4 65 59]["Gr_Inv_2" 3 25 60]["Op_A1" 3 55 61]["Op_B1" 3 55 61] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["For_Ges_Proy" 2 40 62]["GCVV_S" 3 30 63]["Sem_Proy_Grad" 1 20 64]["Op_A2" 3 55 65]["Op_B2" 3 55 66]["Op_C1" 3 55 67] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     set msemestre (sentence msemestre (list ["HSE" 1 20 68]["Proy_Grad" 6 70 69]["Op_A3" 3 55 70]["Op_B3" 3 55 71]["Op_C2" 3 55 72]["Op_D1" 3 55 73] ))
     set curriculum (sentence curriculum (list msemestre))
     set msemestre []
     
      ]
   
   ;sql:exec-query "SELECT abreviatura , o_creditos, p_dificultad, id_materia FROM martha.materia WHERE proyecto = ? 
   ;AND o_semestre = ?" (list numproyecto semestre) 
   ;while [sql:row-available?]
   ; [set msemestre (sentence msemestre (list sql:fetch-row))]
   ; set curriculum (sentence curriculum (list msemestre))
   ; set semestre semestre + 1 ]
 ;sql:disconnect 
end

;==========================================================================================
; Número de créditos del plan
;==========================================================================================
to calCreditsPlan 
 if
   numproyecto = 1 [
     set numCreditsPlan 180
      ] 
 print (word "créditos del plan " numCreditsPlan)
end


;==========================================================================================
;Crea la lista de materias que se distribuyen en el mundo
;las columnas son los semestres y las filas las materias
;==========================================================================================
to setup-subjects
 ask patches [set pcolor 1.5]
 let cordx 0
 let cordy 0
 foreach curriculum[
   set cordx ?
   print (word "cordx" cordx)
   ;show position cordx curriculum
   foreach cordx [
     ;print (word "prueba2")
     set cordy ?
     ;show position cordy cordx
     ask patches with [position cordx curriculum = (pxcor / 4 + 4.5) and position cordy cordx = (pycor / -4 + 4)  ][
       sprout-subjects 1[
         set name item 0 cordy
         set credits item 1 cordy
         set dificult item 2 cordy
         set color 87 set size 2.5
         set label-color 25
         set label name
       ] ]
   ] 
 ]
end
;===================================================================


;===========Carga estudiantes con atributos pre-cargados
to loadStudents 
set selecStudents(list ["20161020563" "M" 3 22 "Bogota" 325 "Ordinaria" "2019" "2019-3"]["20161020505" "F" 3 22 "Bogota" 325 "Ordinaria" "2019" "2019-1"])
set totStudentC num_students

 ; sql:exec-query "SELECT * FROM ( SELECT distinct id_codest, genero, estrato, edad_ing, l_nac, p_icfes, t_inscripcion, 
 ; ano_ing, periodo_ing FROM martha.estudiante WHERE proyecto = ?) as a ORDER BY RANDOM() LIMIT ?" (list 
 ; numproyecto num_students)
;while [sql:row-available?]
 ; [set selecStudents (sentence selecStudents (list sql:fetch-row))]
;print (word "estudiantes de BD " selecStudents)
;set totStudentC num_students
print (word "estudiantes seleccionados " totStudentC) 
; validateC
end

;==================================================



to setup-students
create-students num_students [
 let act_estudiante first selecStudents
 set numMatriculas 0
 set CreditsDisp 18
 set AcadPerformance 0
 set SemesterE 1
 set statusA 1
 set CodStudent item 0 act_estudiante
 set Gender item 1 act_estudiante
 set Stratum item 2 act_estudiante
 set Age item 3 act_estudiante
 set Birthplace item 4 act_estudiante
 set ScoreIcfes item 5 act_estudiante
 set TypeRegister item 6 act_estudiante
 set YearIn item 7 act_estudiante
 set PeriodIn item 8 act_estudiante
 set CurrentPeriod PeriodIn
 set CurrentYear YearIn
 set enrolledSubjects []
 set approvedSubjects []
 set lostSubjects []
 set pendingSubjects []
 initPendingSubjects
 setxy coord_inX coord_inY
 set color 66
 set size 3
 set selecStudents butfirst selecStudents
]
end

;=============

to initPendingSubjects
 let semestre 0
 let materia 0
 foreach curriculum [
 set semestre ?
 foreach semestre[
 set materia ? 
 set pendingSubjects (sentence pendingSubjects (item 0 materia)) ] ]
end

;===========================

;=======Hace el bucle en cada semestre
to go
  if stopProgram = true[stop]
  Print " "
  Print " ________________ corte semestral __________________ "
  Print " "
  cursar_semestre 
  changeColorMoveStudents
  if not any? students with [StatusA < 4 ][ set stopProgram true] ;saveSimulation] 
  if ticks > limiteMatriculas [set stopProgram true] ;saveSimulation] 
  tick
  stateStudents 
end
;=====================================

; Termina la ejecución de los estudiantes con estados de: ; Deserción, Egresados y Perdida de calidad de estudiantes
;==========================================================================================
to stateStudents
 ask students[
 if StatusA > 3 
 [die] ]
end

;Cambia el color de los estudiantes acorde al estado. 
;mueve el estudiante al semestre de la materia más baja
;====================================================================================== 
to changeColorMoveStudents
ask students[
 setxy (coord_inX + (4 * (SemesterE - 1))) coord_inY 
 ifelse StatusA > 4 
 [ ifelse StatusA = 5 
 [set color blue set totStudentE totStudentE + 1]
 [set color red set totStudentPCE totStudentPCE + 1 ] 
 Die ]
 [if StatusA = 2 [set color orange]
 if StatusA = 3 [set color green]
 if StatusA = 1 [set color 28 ] ]]
end


to cursar_semestre 
  ask students [ 
    Print " "
    print CodStudent
    print " "
    incr_period
    register-subjects
    reportar-notas 
    validarPerdidaCalidad
    SaveRegSem 
    print (word "Semestre en curso " SemesterE) 
    print (word "lostSubjects " lostSubjects)
    print (word "approvedSubjects " approvedSubjects)
    print (word "Estado prueba " StatePrueba )
    print (word "número de pruebas " NumPruebas ) 
    print (word "Rendimiento académico " AcadPerformance)
    print (word "estado del estudiante en el semestre " StatusA) ]
end

to validarPerdidaCalidad 
  if StatusA < 4[
    let caso1 0
    let caso2 0
    ; Caso 1: Promedio < 3.2 por 4 periodos
    ;sql:exec-query "select count(*) from martha.reg_semestral where estudiante = ? and (prueba = 100 or prueba = 120 or 
    ;prueba = 103 or prueba = 123)" (list CodStudent)
  ;set caso1 first sql:fetch-row
  ; Caso 2: Haber reprobado 3 o más espacios por 4 periodos 
  ;sql:exec-query "select count(*) from martha.reg_semestral where estudiante = ? and (prueba = 20 or prueba = 120 or prueba 
  ;= 23 or prueba = 123)" (list CodStudent)
set caso2 first sql:fetch-row
; Caso 3: Reprobar 1 o más espacios hasta por 3ra o 4ta vez
; Sólo se puede reprobar 4 veces si ha aprobado más del 70 % del total de créditos académicos del plan
; Este caso se valida en el método validar_causalesPA. ; Si supera el límite de matriculas
if numMatriculas = limiteMatriculas and StatusA != 5
  [ set StatusA 10
    print (word "SUPERA NUMERO MATRICULAS “ StatusA)
      set totsuperaMat totsuperaMat + 1 ] 
    ; Si el número de casos 1 y 2 es mayor a 3 pierde calidad de estudiante 
    if caso1 > 3 
    [set StatusA 8
      print (word "estatus 8 ? " StatusA) ]
    if caso2 > 3 
    [set StatusA 9
      print (word "estatus 9 ? " StatusA) ] ] 
end

to incr_period
 if numMatriculas != 0 [ifelse CurrentPeriod = 1
 [set CurrentPeriod CurrentPeriod + 1]
 [ set CurrentPeriod 1
 set CurrentYear CurrentYear + 1] ]
 print (word "Periodo actual " CurrentYear CurrentPeriod) 
end
 
to register-subjects
 if StatusA < 4 
 [ calcCreditsDisp
 print (word "créditos disponibles " CreditsDisp) 
 set enrolledSubjects []
 print (word "Materias pendientes " pendingSubjects)
 let nsubject 0 let state 0
 if empty? lostSubjects = false 
 [ foreach lostSubjects
 [ enroll(item 0 ?) (item 1 ?) (item 2 ?) ] ]
 foreach pendingSubjects
 [ if creditsDisp > 0 
 [ enroll(?) (0) (?) ] ] 
 print (word "Materias inscritas" enrolledSubjects) 
 set lostSubjects [] 
 set numMatriculas numMatriculas + 1 
 print (word "número de matriculas " numMatriculas)
 ]
end
 
to reportar-notas
  if StatusA < 4 
  [ let posicion 0 let fp 1.0 let valor 0 let probabilidadP 0 let nsubject 0 let estsubject 0 let id_materia 0 let nota 0 let 
    creditsmat 0 let creditsem 0 let dificul 0
    set AverageSem 0 let minimo 3 let notax 0 let notafe 0 let materia 0 let notae 0 let k 0 let v 0 let i 0 let z 0 let porcentaje-aprobacion-apoyo 0.66 
    let j 0 let notains 0 let y 0 let notaapo 0 let suma-gana 0 let suma-pierde 0 let m 0 let notaestrato 0 
    set fbayese [0.65 0.65 0.66 0.71 0.75 0.80 ] set fbayesi [0.65 0.64 0.76 0.74 0.39 0.73 ] set fbayesap [0.40 0.28 0.70 0.77 
    ] 
    print who
    foreach enrolledSubjects 
    [set nsubject item 0 ? set estsubject item 1 ? set id_materia item 2 ? set dificul item 3 ? 
      set posicion (find_subject(nsubject))
      set creditsmat item 1 item (item 1 posicion) item (item 0 posicion) curriculum 
      set creditsem creditsem + creditsmat
      set probabilidadP item 2 item (item 1 posicion) item (item 0 posicion) curriculum 
      ifelse Gender = "M"
      [set i Stratum - 2
        set j TypeRegister - 1
        set k foodAssistance ]
      [set i Stratum + 1
        set j TypeRegister + 2
        set k foodAssistance + 2 ]
      set z ( random-float 1) 
      print (word " z :: " z ) 
      ifelse (z < 0.12) ; ( (item i fbayese))) 
      [ print (word "(item i fbayese perder :: " (item i fbayese))
        set notaestrato ( 1 + (random-float 1.9)) 
        print (word "nota estrato perder :: " notaestrato ) 
        set suma-pierde suma-pierde + 1 ]
      [ set notaestrato ((random-float 2) + 3 ) 
        set suma-gana suma-gana + 1 
        print (word "nota estrato pasar :: " notaestrato ) ] 
      set y ( random-float 1) ; ---> ifelse (( random-float 1) < 1 - (item i fbayesi)) 
      ifelse (y < (1 - (item j fbayesi))) 
      [ print (word "y :: " y)
        set notains ( 1 + (random-float 1.9)) ]
      [ set notains ((random-float 2) + 3 ) ] 
      set v ( random-float 1) ;---->ifelse (( random-float 1) < 1 - (item i fbayese)) 
      ifelse (v < (1 - (item k fbayesap))) 
      [ print (word "k :: " k)
        set notaapo ( 1 + (random-float 1.9)) ]
      [ set notaapo ((random-float 2) + 3 ) ] 
      set notafe notaestrato 
      set notafe (notaestrato + notains + notaapo ) / 3
      set m (random-float 1 + (abs estsubject)*(0.05))
      ifelse ( m ) < probabilidadP
      [ set notax (1 + (random-float 1.9))]
      [ set notax ((random-float 2) + 3)]
      set nota (notafe + notax ) / 2 
      ---> FACTOR DE PR5OFESOR ; "Aceptable" "Excelente" > 0.8 and factor_profesor <= 1 "Bueno" > 0.6 and 
      factor_profesor <= 0.8 
      print (word "FProfesor :: " fp)
      print (word "nota antes fp :: " nota) 
      set fp precision ( random-float(1 - 0.5) + 0.5) 2 
      if activar-factor-profesor 
      [ifelse fp > 0.8
        [set nota nota + 0.10 ]
        [ifelse fp > 0.6
          [set nota nota + 0.08 ]
          [set nota nota + 0.01] ]
      ] if nota > 5.0
      [set nota 5.0] 
      print (word "FProfesor :: " fp)
      print (word "nota con fp :: " nota)
      if activar-apoyo-alimentario 
      [set nota nota + 0.15 
        print (word "minimo nota apoyo :: " minimo ) ] 
      ifelse nota < 3
      [set lostSubjects (sentence lostSubjects (list (list nsubject (estsubject - 1) id_materia)))
        set TLost TLost + 1
        set semestralStudentGrades(sentence semestralStudentGrades (list  CurrentYear CurrentPeriod nota (estsubject - 1) CodStudent id_materia numMatriculas ))
        ;sql:exec-update "INSERT INTO martha.estudiante_materia(anio, periodo, nota_def, estado, estudiante, materia, 
        ;matricula) VALUES (?, ?, ?, ?, ?, ?, ?)" (list CurrentYear CurrentPeriod nota (estsubject - 1) CodStudent id_materia 
      ;numMatriculas)
    changeColorSubject(nsubject)(estsubject - 1) ][
  set approvedSubjects (sentence approvedSubjects (list (list nsubject 1 id_materia))) 
  set TApproved TApproved + 1
  set nota precision (random-float 2 + 3) 2
  set semestralStudentGrades(sentence semestralStudentGrades (list  CurrentYear CurrentPeriod nota 1 CodStudent id_materia numMatriculas ))
 ; sql:exec-update "INSERT INTO martha.estudiante_materia(anio, periodo, nota_def, estado, estudiante, materia, 
 ; matricula) VALUES (?, ?, ?, ?, ?, ?, ?)"(list CurrentYear CurrentPeriod nota 1 CodStudent id_materia numMatriculas)
  changeColorSubject(nsubject)(1) ]
set AverageSem AverageSem + ( nota * creditsmat )
set pendingSubjects remove nsubject pendingSubjects 
set TEnrolled TLost + TApproved ] 
if empty? enrolledSubjects = false 
  [set SemesterE item 0 (find_subject(first first enrolledSubjects)) + 1
    set AverageSem precision (AverageSem / creditsem ) 2 ]
ifelse numMatriculas = 1
  [set AccumAverage AverageSem]
  [set AccumAverage precision ((AccumAverage + AverageSem ) / 2) 2]
;; Termina materias si en las materias aprobadas estan todas excepto gr2
if TApproved >= (((count subjects)) - 1)
  [set StatusA 3] 
;; Se gradua si ya supero el plan de estudios
if empty? pendingSubjects and empty? lostSubjects
  [set StatusA 5 ] 
calIndex 
validarCausalesPA 
calctotTerminoM ]
 end

to calIndex 
 set repetitionIndex precision (TLost / TEnrolled) 2
 set backwardnessIndex precision (1 - (SemesterE / numMatriculas)) 2 
 set permanenceIndex precision (calcNumSemIn / numMatriculas ) 2
 set nivelIndex precision (TApproved / calcNumSub) 2 
 calcAcadPerformance
end

to validarCausalesPA 
 if StatusA < 3 [
 set StatePrueba ""
 ;;promedio del semestre inferior a 3.2
 if AverageSem < 3.2
 [set StatePrueba (word StatePrueba 1)
 set totPaAverage totPaAverage + 1]
 ;; perder 3 materias
 let num_lost_subj length lostSubjects
 ifelse num_lost_subj > 2 
 [set StatePrueba (word StatePrueba 2)
 set totPaThree totPaThree + 1]
 [if empty? StatePrueba = false[set StatePrueba (word StatePrueba 0)]]
 ;; perder por tercera vez una materia
 let max_lost 0
 foreach lostSubjects [
 if item 1 ? < max_lost
 [set max_lost item 1 ?] ]
 ifelse max_lost < -2 
 [set StatePrueba (word StatePrueba 3)
 set totPaThird totPaThird + 1
 ifelse max_lost = -3
 [if calCreditsApproved < ((70 * numCreditsPlan) / 100)
 [ set StatusA 6 ]] 
 [set StatusA 7 ] ]
 [set StatePrueba (word StatePrueba 0)]
 ifelse StatePrueba != "0" 
 [set NumPruebas NumPruebas + 1 
 if StatusA < 6 [set StatusA 2]]
 [set StatusA 1] ] 
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
883
704
25
25
13.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks

SWITCH
8
293
204
326
activar-control-matriculas
activar-control-matriculas
0
1
-1000

CHOOSER
28
176
182
221
proyectoIng
proyectoIng
"ING DE SISTEMAS"
0

SLIDER
19
243
191
276
num_students
num_students
1
2
1
1
1
NIL
HORIZONTAL

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
