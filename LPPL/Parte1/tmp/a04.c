//Ejemplo de secuencias de instrucciones y declaraciones 
{ bool z = true;     
  int  x; read(x);

  if ((x <= 9) && (x >= 0)) z = true; else z = false;

  int  a[10];
  int  i=0; 
  while (i < 10) {
    a[i] = i; i++;
  }
  if (z) i = a[x]; else {}
  print(i);
}
