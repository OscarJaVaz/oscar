/// Ejercicio 4 - Sección 1: Combinación de suma objetivo
library;

// ignore_for_file: avoid_print

bool combinacionSumaObjetivo(List<int> numeros, int objetivo) {
  return _buscar(numeros, objetivo, 0, 0);
}

bool _buscar(List<int> numeros, int objetivo, int indice, int sumaActual) {
  if (sumaActual == objetivo) return true;
  if (indice >= numeros.length || sumaActual > objetivo) return false;
  if (_buscar(numeros, objetivo, indice + 1, sumaActual + numeros[indice])) {
    return true;
  }
  return _buscar(numeros, objetivo, indice + 1, sumaActual);
}

void main() {
  final casos = [
    ([2, 5, 8, 44, 1, 7], 9),
    ([55, 3, 8, 11, 45, 1], 12),
    ([4, 8, 48, 44, 1], 11),
  ];

  for (final (numeros, objetivo) in casos) {
    final resultado = combinacionSumaObjetivo(numeros, objetivo);
    print('Entrada: $numeros, objetivo: $objetivo');
    print('Salida:  ${resultado ? 'TRUE' : 'FALSE'}');
    print('---');
  }
}

//para correr el ejercicio en la terminal ejecutar el comando: dart run ejercicios/seccion1/ejercicio4.dart