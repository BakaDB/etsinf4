// Criba de Eratostenes: calcula los numeros primos > 1 y < 150
{
  bool a[150];
  int max;       // Numero a buscar
  int n;         // Siguiente numero primo
  int i;
  bool OK=false;

  // Comprobacion de que es un numero admisible
  while ( !OK ) {
    read(max);
    if ((max > 1) && (max < 150)) OK = true;
    else {}
  }
  // Inicializacion del vector de posible primos
  i = 2;
  while (i <= max) { a[i] = true; i++; }

  // Criba de Earatostenes
  n = 2; OK = false;
  while ( !OK ) {
    // Eliminacion de los multiplos de "n"
    i = 2;
    while ((i * n) <= max) { a[i*n] = false; i++; }
    // Busqueda del siguiente primo
    i = n + 1;
    while (! a[i] && (i <= max)) {i++;}
    // Control del fin (n * n > max)
    if ((i * i) <= max) n = i;
    else OK = true;
  }
  // visualizacion de los primos menores que "max"
  i = 2;
  while (i <= max) {
    if (a[i]) print(i); else {};
    i++;
  }
}
