(define (problem MANTENIMIENTO-CARRETERAS-1)
(:domain mantenimiento-carreteras)

(:objects    
    tramo1 tramo2 tramo3 tramo4 tramo5 - tramo
    cuadrilla1 cuadrilla2 cuadrilla3 cuadrilla4 - cuadrilla
    cisterna1 cisterna2 - cisterna
    pavimentadora1 pavimentadora2 - pavimentadora
    compactadora1 - compactadora
)

(:init
    (available tramo1)
    (available tramo2)
    (available tramo3)
    (available tramo4)
    (available tramo5)

    (available cuadrilla1)
    (available cuadrilla2)
    (available cuadrilla3)
    (available cuadrilla4)

    (available cisterna1)
    (available cisterna2)

    (available pavimentadora1)
    (available pavimentadora2)

    (available compactadora1)

    (at cuadrilla1 tramo1)
    (at cuadrilla2 tramo1)
    (at cuadrilla3 tramo5)
    (at cuadrilla4 tramo5)
    
    (at cisterna1 tramo1)
    (at cisterna2 tramo1)

    (at pavimentadora1 tramo2)
    (at pavimentadora2 tramo2)

    (at compactadora1 tramo5)

    (connected tramo1 tramo2)
    (connected tramo2 tramo1)
    (connected tramo2 tramo3)
    (connected tramo2 tramo4)
    (connected tramo3 tramo2)
    (connected tramo3 tramo5)
    (connected tramo4 tramo2)
    (connected tramo4 tramo5)
    (connected tramo5 tramo3)
    (connected tramo5 tramo4)

    (needs-compactado tramo1)
    (needs-compactado tramo2)
    
    (needs-pavimentado tramo3)
    (needs-pavimentado tramo4)
    (needs-pavimentado tramo5)

    (needs-pintado tramo1)
    (needs-pintado tramo2)
    (needs-pintado tramo3)
    (needs-pintado tramo4)
    (needs-pintado tramo5)

    (needs-vallado tramo1)
    (needs-vallado tramo2)
    (needs-vallado tramo3)
    (needs-vallado tramo4)
    (needs-vallado tramo5)

    (needs-senalizado tramo3)
    (needs-senalizado tramo4)
    (needs-senalizado tramo5)

    (= (duracion-mover-maquinaria tramo1 tramo2) 10)
    (= (duracion-mover-maquinaria tramo2 tramo1) 10)
    (= (duracion-mover-maquinaria tramo2 tramo3) 12)
    (= (duracion-mover-maquinaria tramo2 tramo4) 8)
    (= (duracion-mover-maquinaria tramo3 tramo2) 12)
    (= (duracion-mover-maquinaria tramo3 tramo5) 14)  
    (= (duracion-mover-maquinaria tramo4 tramo2) 8)  
    (= (duracion-mover-maquinaria tramo4 tramo5) 12)
    (= (duracion-mover-maquinaria tramo5 tramo3) 14)
    (= (duracion-mover-maquinaria tramo5 tramo4) 12)

    (= (duracion-mover-cuadrilla tramo1 tramo2) 5)
    (= (duracion-mover-cuadrilla tramo2 tramo1) 5)
    (= (duracion-mover-cuadrilla tramo2 tramo3) 6)
    (= (duracion-mover-cuadrilla tramo2 tramo4) 4)
    (= (duracion-mover-cuadrilla tramo3 tramo2) 6)
    (= (duracion-mover-cuadrilla tramo3 tramo5) 7)
    (= (duracion-mover-cuadrilla tramo4 tramo2) 4)    
    (= (duracion-mover-cuadrilla tramo4 tramo5) 6)
    (= (duracion-mover-cuadrilla tramo5 tramo3) 7)
    (= (duracion-mover-cuadrilla tramo5 tramo4) 6)

    (= (duracion-compactado) 250)
    (= (duracion-pavimentado) 190)
    (= (duracion-aplastado) 150)
    (= (duracion-pintado) 30)
    (= (duracion-vallado) 120)
    (= (duracion-senalizado) 70)

    (= (coste-cisterna) 25)
    (= (coste-pavimentadora) 30)
    (= (coste-compactadora) 35)

    (= (coste-total) 0)
)

(:goal
    (and
        (at cuadrilla1 tramo1)
        (at cuadrilla2 tramo5)
        (at cuadrilla4 tramo5)

        (at cisterna1 tramo1)
        (at cisterna2 tramo3)

        (at compactadora1 tramo5)

        (completed-pintado tramo1)
        (completed-vallado tramo1)

        (completed-pintado tramo2)
        (completed-vallado tramo2)

        (completed-pintado tramo3)
        (completed-vallado tramo3)
        (completed-senalizado tramo3)

        (completed-pintado tramo4)
        (completed-vallado tramo4)
        (completed-senalizado tramo4)

        (completed-pintado tramo5)
        (completed-vallado tramo5)
        (completed-senalizado tramo5)
    )    
)

(:metric minimize (+ (* 0.2 (total-time)) (* 0.5 (coste-total))))
)