(define (domain mantenimiento-carreteras)

(:requirements  :durative-actions 
                :typing 
                :fluents
)

(:types         tramo transportable - object
                cuadrilla maquinaria - transportable
                cisterna pavimentadora compactadora - maquinaria
)

(:predicates    (available ?x - object)
                (at ?x - transportable ?t - tramo)
                (connected ?t1 ?t2 - tramo)
                
                (needs-compactado ?t - tramo)
                (needs-pavimentado ?t - tramo)
                (needs-aplastado ?t - tramo)
                (needs-pintado ?t - tramo)
                (needs-vallado ?t - tramo)
                (needs-senalizado ?t - tramo)

                (completed-maintenance ?t - tramo)
                (completed-pintado ?t - tramo)
                (completed-vallado ?t - tramo)
                (completed-senalizado ?t - tramo)
)

(:functions     (duracion-mover-maquinaria ?t1 ?t2 - tramo)
                (duracion-mover-cuadrilla ?t1 ?t2 - tramo)

                (duracion-compactado)
                (duracion-pavimentado)
                (duracion-aplastado)
                (duracion-pintado)
                (duracion-vallado)
                (duracion-senalizado)

                (coste-cisterna)
                (coste-pavimentadora)
                (coste-compactadora)
                (coste-total)
)

;; Discutible disponibilidad de la cuadrilla, maquinaria y los tramos

(:durative-action mover-maquinaria
    :parameters (?m - maquinaria ?t1 ?t2 - tramo)
    :duration   (= ?duration (duracion-mover-maquinaria ?t1 ?t2))
    :condition  (and 
                    (at start (at ?m ?t1))
                    (at start (available ?m))
                    (at start (available ?t1))      ; at start
                    (at start (available ?t2))      ; at end
                    (over all (connected ?t1 ?t2)))
    :effect     (and
                    (at start (not (at ?m ?t1)))
                    (at start (not (available ?m)))
                    (at start (not (available ?t1)))
                    (at start (not (available ?t2)))
                    (at end (at ?m ?t2))
                    (at end (available ?m))
                    (at end (available ?t1))
                    (at end (available ?t2)))
)

(:durative-action mover-cuadrilla
    :parameters (?c - cuadrilla ?t1 ?t2 - tramo)
    :duration   (= ?duration (duracion-mover-cuadrilla ?t1 ?t2))
    :condition  (and 
                    (at start (at ?c ?t1))
                    (at start (available ?c))
                    (at start (available ?t1))      ; at start
                    (at start (available ?t2))      ; at end
                    (over all (connected ?t1 ?t2)))
    :effect     (and
                    (at start (not (at ?c ?t1)))
                    (at start (not (available ?c)))
                    (at start (not (available ?t1)))
                    (at start (not (available ?t2)))
                    (at end (at ?c ?t2))
                    (at end (available ?c))
                    (at end (available ?t1))
                    (at end (available ?t2)))
)

(:durative-action compactado
    :parameters (?t - tramo)
    :duration   (= ?duration (duracion-compactado))
    :condition  (and
                    (at start (needs-compactado ?t))
                    (at start (available ?t)))
    :effect     (and
                    (at start (not (needs-compactado ?t)))
                    (at start (not (available ?t)))
                    (at end (available ?t))
                    (at end (needs-pavimentado ?t)))
)

(:durative-action pavimentado
    :parameters (?t - tramo ?c - cisterna ?p - pavimentadora)
    :duration   (= ?duration (duracion-pavimentado))
    :condition  (and    
                    (at start (needs-pavimentado ?t))
                    (at start (available ?t))
                    (at start (available ?c))
                    (at start (available ?p))
                    (over all (at ?c ?t))
                    (over all (at ?p ?t)))
    :effect     (and
                    (at start (not (needs-pavimentado ?t)))
                    (at start (not (available ?t)))
                    (at start (not (available ?c)))
                    (at start (not (available ?p)))  
                    (at end (available ?t))  
                    (at end (available ?c))
                    (at end (available ?p))
                    (at end (needs-aplastado ?t))
                    (at end (increase (coste-total) (coste-cisterna)))
                    (at end (increase (coste-total) (coste-pavimentadora))))
)

(:durative-action aplastado
    :parameters (?t - tramo ?c - compactadora)
    :duration   (= ?duration (duracion-aplastado))
    :condition  (and
                    (at start (needs-aplastado ?t))
                    (at start (available ?t))
                    (at start (available ?c))
                    (over all (at ?c ?t)))
    :effect     (and
                    (at start (not (needs-pavimentado ?t)))
                    (at start (not (available ?t)))
                    (at start (not (available ?c)))
                    (at end (available ?t))
                    (at end (available ?c))
                    (at end (completed-maintenance ?t))
                    (at end (needs-pintado ?t))
                    (at end (needs-vallado ?t))
                    (at end (increase (coste-total) (coste-compactadora))))
)

(:durative-action pintado
    :parameters (?t - tramo ?c - cuadrilla)
    :duration   (= ?duration (duracion-pintado))
    :condition  (and
                    (at start (completed-maintenance ?t))
                    (at start (needs-pintado ?t))                    
                    (at start (available ?t))
                    (at start (available ?c))
                    (over all (at ?c ?t)))
    :effect     (and 
                    (at start (not (needs-pintado ?t)))                    
                    (at start (not (available ?t)))
                    (at start (not (available ?c)))
                    (at end (available ?t))
                    (at end (available ?c))
                    (at end (completed-pintado ?t)))
)

(:durative-action vallado
    :parameters (?t - tramo ?c - cuadrilla)
    :duration   (= ?duration (duracion-vallado))
    :condition  (and
                    (at start (completed-maintenance ?t))
                    (at start (needs-vallado ?t))                    
                    (at start (available ?t))
                    (at start (available ?c))
                    (over all (at ?c ?t)))
    :effect     (and 
                    (at start (not (needs-vallado ?t)))
                    (at start (not (available ?t)))
                    (at start (not (available ?c)))
                    (at end (available ?t))
                    (at end (available ?c))
                    (at end (completed-vallado ?t)))
)

(:durative-action senalizado
    :parameters (?t - tramo ?c - cuadrilla)
    :duration   (= ?duration (duracion-senalizado))
    :condition  (and
                    (at start (completed-maintenance ?t))
                    (at start (needs-senalizado ?t))
                    (at start (available ?t))
                    (at start (available ?c))
                    (over all (at ?c ?t)))
    :effect     (and 
                    (at start (not (needs-senalizado ?t)))
                    (at start (not (available ?t)))
                    (at start (not (available ?c)))
                    (at end (available ?t))
                    (at end (available ?c))
                    (at end (completed-senalizado ?t)))
)

)

; Para ejecutar 
; lpg-td-1.0 –o dominio.pddl –f problema.pddl –n 3
; Hay que remplazar el lpg-td-1.0 por el nombre del archivo ejecutable 
; que creamos en el primer lab con el señor.
; El que nos echó la bronca por poner -m en vez de -n

;(at start (not (or 
;                        (needs-compactado ?t)
;                        (needs-pavimentado ?t)
;                        (needs-aplastado ?t))))