;AYUDA EN LA TOMA DE DECISIONES SOBRE EL MANTENIMIENTO A REALIZAR DE UNA CARRETERA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Fuzzification function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffunction fuzzify (?fztemplate ?value ?delta)

	(bind ?low (get-u-from ?fztemplate))
	(bind ?hi  (get-u-to   ?fztemplate))

	(if (<= ?value ?low)
	then
		(assert-string (format nil "(%s (%g 1.0) (%g 0.0))" ?fztemplate ?low ?delta))
	else (
		if (>= ?value ?hi)
		then
			(assert-string (format nil "(%s (%g 0.0) (%g 1.0))" ?fztemplate (- ?hi ?delta) ?hi))
		else (
			assert-string (format nil "(%s (%g 0.0) (%g 1.0) (%g 0.0))" ?fztemplate 
							(max ?low (- ?value ?delta)) ?value (min ?hi (+ ?value ?delta)))
		)
	))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Templates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
(deftemplate agrietamiento 0 100 %
	((ligero (0 1) (10 1) (20 0))
	(medio (5 0) (25 1) (45 1) (55 0))
	(fuerte (50 0) (60 1) (100 1)))
)

(deftemplate temperatura -10 90 C
	((fria (0 1) (10 1) (20 0))
	(moderada (5 0) (25 1) (45 1) (55 0))
	(calida (50 0) (60 1) (90 1)))
)

(deftemplate necesidad 0 100 n
	((baja (z 10 25))
	(media (pi 15 60))
	(urgente (s 55 90)))
)

(deftemplate densidad-trafico 0 300 vph
	((baja (z 20 80))
	(alta (s 120 250)))
)

(deftemplate carretera
	(slot id (type SYMBOL)) 
	(slot nivelAgrietamiento (type INTEGER))
	(slot tempMax (type FLOAT))
	(slot tempMin (type FLOAT))
	(slot vehiculosPorHora (type INTEGER))
	(slot prioridad (type FLOAT))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Modify the level of necessity
;;		of repairment the road has
;;		related to the temperature
;;		and state of the road
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule fria_ligero
	(temperatura fria)
	(agrietamiento ligero)
	=>
	(assert (necesidad media))
)

(defrule fria_medio
	(temperatura fria)
	(agrietamiento medio)
	=>
	(assert (necesidad urgente))
)

(defrule fria_fuerte
	(temperatura fria)
	(agrietamiento fuerte)
	=>
	(assert (necesidad extremely urgente))
)

(defrule moderado_ligero
	(temperatura moderada)
	(agrietamiento ligero)
	=>
	(assert (necesidad very baja))
)

(defrule moderado_medio
	(temperatura moderada)
	(agrietamiento medio)
	=>
	(assert (necesidad baja))
)

(defrule moderado_fuerte
	(temperatura moderada)
	(agrietamiento fuerte)
	=>
	(assert (necesidad somewhat baja))
)

(defrule calida_ligero
	(temperatura calida)
	(agrietamiento ligero)
	=>
	(assert (necesidad media))
)

(defrule calida_medio
	(temperatura calida)
	(agrietamiento medio)
	=>
	(assert (necesidad very urgente))
)

(defrule calida_fuerte
	(temperatura calida)
	(agrietamiento fuerte)
	=>
	(assert (necesidad extremely urgente))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Modify the level of necessity
;;		of repairment the road has
;;		related to it's traffic density
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule densidad_alta
	(declare (salience 0))
	(densidad-trafico alta)
	=>
	(assert (necesidad very urgente))
)

(defrule densidad_baja
	(declare (salience 0))

	(densidad-trafico baja)
	=>
	(assert (necesidad more-or-less baja))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Define the road id, tempMin,
;;		tempMax and agrietamiento to
;;		start the execution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffunction main()
	(reset)
 	(printout t "Introduce identificador de la carretera:" crlf)
	(bind ?id (read))
	
 	(printout t "Introduzca el nivel de agrietamiento del asfalto en 0 a 100%:" crlf)
	(bind ?nivel_agrietamiento (read))
	
	(printout t "Introduzca temperatura mínima en grados (-10:90):" crlf)
	(bind ?temp_min (read))
	
	(printout t "Introduzca temperatura máxima en grados (-10:90):" crlf)
	(bind ?temp_max (read))
	
	(printout t "Introduzca los vehiculos que pasan por hora por la carretera (0:300):" crlf)
	(bind ?vph (read))
	
	(fuzzify agrietamiento ?nivel_agrietamiento 0.1)
	(fuzzify temperatura ?temp_min 0.1)
	(fuzzify temperatura ?temp_max 0.1)
	(fuzzify densidad-trafico ?vph 0.1)
	
	(assert (carretera (id ?id) (nivelAgrietamiento ?nivel_agrietamiento) (tempMax ?temp_max) (tempMin ?temp_min) (vehiculosPorHora ?vph) (prioridad 0.0)))
	;(run)
)

(defrule defuzzy	
	(declare (salience -1))
	(necesidad ?n)
	?c <- (carretera (id ?id) (nivelAgrietamiento ?nivel_agrietamiento) (tempMax ?temp_max) (tempMin ?temp_min) (vehiculosPorHora ?vph) (prioridad ?))
 	=>
	(bind ?p (moment-defuzzify ?n))
  	(modify ?c (prioridad ?p))
	;(retract ?c)
	;(assert (carretera (id ?id) (nivelAgrietamiento ?nivel_agrietamiento) (tempMax ?temp_max) (tempMin ?temp_min) (vehiculosPorHora ?vph) (prioridad ?p)))
 	(printout t "Necesidad del asfaltado: " ?p crlf)
 	(halt)
)
