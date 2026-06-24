/// Ejercicio 2 - Sección 1: Filtrado de números pares únicos
library;

// ignore_for_file: avoid_print

List<int> filtrarParesUnicos(List<int> numeros) {
  final vistos = <int>{};
  return numeros.where((n) => n % 2 == 0 && vistos.add(n)).toList();
}

void main() {
  final casos = [
    [2, 7, 9, 12, 33, 15, 22, 12, 4],
    [1, 2, 3, 4, 5, 6, 7, 2, 4, 6, 8, 6],
  ];

  for (final entrada in casos) {
    final salida = filtrarParesUnicos(entrada);
    print('Entrada: $entrada');
    print('Salida:  $salida');
    print('---');
  }
}

//para correr el ejercicio en la terminal ejecutar el comando: dart run ejercicios/seccion1/ejercicio2.dart