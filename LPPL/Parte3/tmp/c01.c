// Ejemplo (rebuscado) del uso de operadores logicos
// Lee un par de numeros "x" e "y": Si "x>y" imprime un "1"
// y termina; si "x<y" imprime un "0" y termina; y repite
// la lectura si son iguales o alguno es 0 
{ bool z = true; int x; int y;

  while (z) {
    read(x); read(y);
    if ((x != y) || false) {         
      if ( !(x == 0) && !(y == 0) && true)
        if (x > y)
	  { print(1); z = false; }
        else { print(0); z = false; }
      else {}
    } 
    else {}
  }
}
