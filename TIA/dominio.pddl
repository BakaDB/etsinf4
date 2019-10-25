(define (domain matenimiento-carreteras)
(:requirements :durative-actions :typing :fluents)
(:types tramo transportable - object
        cuadrilla maquinaria - transportable
        cisterna pavimentadora compactadora - maquinaria)

(:predicates    (available ?x - object)
                ;(available ?x - tramo)
                ;(available ?x - cuadrilla)
                ;(available ?x - cisterna)
                ;(available ?x - pavimentadora)
                ;(available ?x - compactadora)

                (at ?x - transportable ?t - tramo)
                ;(at ?x - cuadrilla ?t - tramo)
                ;(at ?x - cisterna ?t - tramo)
                ;(at ?x - pavimentadora ?t - tramo)
                ;(at ?x - compactadora ?t - tramo)

                (needs-compactado ?t - tramo)
                (needs-pavimentado ?t - tramo)
                (needs-aplastado ?t - tramo)
                (needs-señalizado ?t - tramo)
                (needs-pintado ?t - tramo)
                (needs-vallado ?t - tramo)
                (needs-señalizado ?t - tramo)
                (connected ?t1 ?t2 - tramo)
)

(:functions     (duracion-mover-maquinaria ?t1 - tramo ?t2 - tramo)
                (duracion-mover-cuadrilla ?t1 - tramo ?t2 - tramo)

                (duracion-compactado)
                (duracion-pavimentado)
                (duracion-aplastado)
                (duracion-pintado)
                (duracion-vallado)
                (duracion-señalizado)

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
                    (at ?m ?t1) 
                    (connected ?t1 ?t2) 
                    (over all (available ?m))
                    (over all (available ?t1))
                    (over all (available ?t2)))
    :effect     (and 
                    (at start (not (at ?m ?t1)))
                    (at end (at ?m ?t2)))
)

(:durative-action mover-cuadrilla
    :parameters (?c - cuadrilla ?t1 ?t2 - tramo)
    :duration   (= ?duration (duracion-mover-cuadrilla ?t1 ?t2))
    :condition  (and 
                    (at ?c ?t1) 
                    (connected ?t1 ?t2) 
                    (over all (available ?c))
                    (over all (available ?t1))
                    (over all (available ?t2)))
    :effect     (and 
                    (at start (not (at ?c ?t1)))
                    (at end (at ?c ?t2)))
)

(:durative-action compactado
    :parameters (?t - tramo)
    :duration   (= ?duration (duracion-compactado))
    :condition  (and
                (needs-compactado ?t)
                (over all (available ?c)))
    :effect     (and
                    (at start (not (needs-compactado ?t)))
                    (at end (needs-compactado ?t))
                    (at end (increase (coste-total) (coste-compactado))))
)

(:durative-action pavimentado
    :parameters (?t - tramo ?c - cisterna ?p - pavimentadora)
    :duration   (= ?duration (duracion-pavimentado))
    :condition  (and    
                    (needs-pavimentado ?t)                
                    (over all (at ?c ?t))
                    (over all (at ?p ?t))
                    (over all (available ?c))
                    (over all (available ?p))
                    (over all (available ?t)))
    :effect     (and
                    (at start (not (needs-pavimentado ?t)))
                    (at end (needs-aplastado ?t))
                    (at end (increase (coste-total) (coste-pavimentado))))
)

(:durative-action aplastado
    :parameters (?t - tramo ?c - compactadora)
    :duration   (= ?duration (duracion-aplastado))
    :condition  (and
                    (needs-aplastado ?t)
                    (over all (at ?c ?t))
                    (over all (available ?c))
                    (over all (available ?t)))
    :effect     (and
                    (at start (not (needs-pavimentado ?t)))
                    (at end (needs-pintado ?t))
                    (at end (needs-vallado ?t))
                    (at end (increase (coste-total) (coste-aplastado))))
)

(:durative-action pintado
    :parameters (?t - tramo ?c - cuadrilla)
    :duration   (= ?duration (duracion-pintado))
    :condition  (and
                    (not (or 
                        (needs-compactado ?t)
                        (needs-pavimentado ?t)
                        (needs-aplastado ?t)))
                    (needs-pintado ?t)
                    (over all (at ?c ?t))
                    (over all (available ?c))
                    (over all (available ?t)))
    :effect     ((at start (not (needs-pintado ?t))))
)

(:durative-action vallado
    :parameters (?t - tramo ?c - cuadrilla)
    :duration   (= ?duration (duracion-vallado))
    :condition  (and
                    (not (or 
                        (needs-compactado ?t)
                        (needs-pavimentado ?t)
                        (needs-aplastado ?t)))
                    (needs-vallado ?t)
                    (over all (at ?c ?t))
                    (over all (available ?c))
                    (over all (available ?t))))
    :effect     ((at start (not (needs-vallado ?t))))
)

(:durative-action señalizado
    :parameters (?t - tramo ?c - cuadrilla)
    :duration   (= ?duration (duracion-señalizado))
    :condition  (and
                    (not (or 
                        (needs-compactado ?t)
                        (needs-pavimentado ?t)
                        (needs-aplastado ?t)))
                    (needs-señalizado ?t)
                    (over all (at ?c ?t))
                    (over all (available ?c))
                    (over all (available ?t))))
    :effect     ((at start (not (needs-señalizado ?t))))
)

)