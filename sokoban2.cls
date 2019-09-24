;AYUDA EN LA TOMA DE DECISIONES SOBRE EL MANTENIMIENTO A REALIZAR DE UNA CARRETERA

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
			
(deftemplate agrietamiento 0 100 %
	(ligero (0 1) (10 1) (20 0))
	(medio (5 0) (25 1) (45 1) (55 0))
	(fuerte (50 0) (60 1) (100 1))
)

(deftemplate temperatura -10 90 C
	(fria (0 1) (10 1) (20 0))
	(moderada (5 0) (25 1) (45 1) (55 0))
	(calida (50 0) (60 1) (100 1))
)

(deftemplate necesidad 0 100 m
	(baja (z 10 25))
	(media (pi 15 60))
	(urgente (s 55 90))
)

(deftemplate carretera 
	(slot agrietamiento (type INTEGER))
	(slot tempMax (type INTEGER))
	(slot tempMin (type INTEGER))
	(slot prioridad (type FLOAT))
)

(deffunction proceso ()
	(reset)
	
	;leer valores difusos
	(printout t "Introduzca el nivel de agrietamiento del asfalto: ligero, medio, fuerte" crlf)
	(bind ?Redad (read))
	(assert-string (format nil "(agrietamiento %s)" ?Redad))
	
	;leer valores crisp y fusificar
	(printout t "Introduzca temperatura mínima en grados" crlf) ;leemos un valor crisp y se fusifica (y aserta)
	(bind ?Redad (read))
	(fuzzify tempMin ?Redad 0.1)
	
	(printout t "Introduzca temperatura máxima en grados" crlf) ;leemos un valor crisp y se fusifica (y aserta)
	(bind ?Redad (read))
	(fuzzify tempMax ?Redad 0.1)
	(run)
	
	
	
	?f<-(carretera (nivel ) (tempMax ) (tempMin )))
	(test (?necesidad))
		=>
	(fuzzify carretera)
	;necesidad
	
	
)

;necesidad-reasfaltado
;	very 				baja ligero-moderada
;	baja				medio-moderado
;	somewhat media		fuerte-moderado
;	media				ligero-fria ligero-calida
;	urgente				medio-fria
;	very urgente		medio-calida
;	extremely urgente	fuerte-fria fuerte-calida














