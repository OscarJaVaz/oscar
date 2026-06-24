/// Ejercicio 1 - Sección 1: Inversión de palabras respetando el orden
library;

// ignore_for_file: avoid_print

String invertirPalabras(String cadena) {
  return cadena
      .split(' ')
      .map((palabra) => palabra.split('').reversed.join())
      .join(' ');
}

void main() {
  final casos = [
    'Hola soy una cadena',
    'Programando ando',
    'Concatenación',
  ];

  for (final entrada in casos) {
    final salida = invertirPalabras(entrada);
    print('Entrada: "$entrada"');
    print('Salida:  "$salida"');
    print('---');
  }
}

//para correr el ejercicio en la terminal ejecutar el comando: dart run ejercicios/seccion1/ejercicio1.dart