/// Ejercicio 3 - Sección 1: Primos gemelos en rango
library;

// ignore_for_file: avoid_print

bool esPrimo(int n) {
  if (n < 2) return false;
  if (n == 2) return true;
  if (n % 2 == 0) return false;
  for (int i = 3; i * i <= n; i += 2) {
    if (n % i == 0) return false;
  }
  return true;
}

List<(int, int)> primosGemelos(int inicio, int fin) {
  final pares = <(int, int)>[];
  for (int n = inicio; n <= fin - 2; n++) {
    if (esPrimo(n) && esPrimo(n + 2)) {
      pares.add((n, n + 2));
    }
  }
  return pares;
}

void main() {
  final casos = [
    (0, 10),
    (100, 150),
    (700, 800),
  ];

  for (final (inicio, fin) in casos) {
    final resultado = primosGemelos(inicio, fin);
    print('Rango [$inicio, $fin]:');
    if (resultado.isEmpty) {
      print('0:  Sin primos gemelos en este rango');
    } else {
      for (final par in resultado) {
        print('  (${par.$1}, ${par.$2})');
      }
    }
    print('---');
  }
}

//para correr el ejercicio en la terminal ejecutar el comando: dart run ejercicios/seccion1/ejercicio3.dart