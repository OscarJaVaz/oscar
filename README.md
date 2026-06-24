# Prueba Técnica — Oscar

Solución completa dividida en dos secciones: ejercicios lógico-matemáticos en Dart puro y una app Flutter offline-first.

---

## Tabla de contenidos

1. [Estructura del repositorio](#estructura-del-repositorio)
2. [Sección 1 — Ejercicios lógico-matemáticos](#sección-1--ejercicios-lógico-matemáticos)
3. [Sección 2 — App Flutter](#sección-2--app-flutter)
   - [Arquitectura](#arquitectura)
   - [Gestión de estado con Riverpod](#gestión-de-estado-con-riverpod)
   - [Persistencia local SQLite](#persistencia-local-sqlite)
   - [Diseño responsivo](#diseño-responsivo)
   - [Concurrencia con Isolates](#concurrencia-con-isolates)
   - [Navegación](#navegación)
   - [Paquetes utilizados](#paquetes-utilizados)
4. [Cómo ejecutar](#cómo-ejecutar)

---

## Estructura del repositorio

```
oscar/
├── ejercicios/                        # Sección 1 — Dart puro (package independiente)
│   ├── pubspec.yaml
│   └── seccion1/
│       ├── ejercicio1.dart            # Inversión de palabras
│       ├── ejercicio2.dart            # Filtrado de pares únicos
│       ├── ejercicio3.dart            # Primos gemelos en rango
│       ├── ejercicio4.dart            # Combinación de suma objetivo
│       └── ejercicio5.sql             # Consulta relacional SQLite
│
├── lib/                               # Sección 2 — App Flutter
│   ├── main.dart
│   ├── config/router/app_router.dart
│   ├── domain/
│   │   ├── entities/task.dart
│   │   └── repositories/task_repository.dart
│   ├── infrastructure/
│   │   ├── datasources/task_datasource.dart
│   │   ├── mappers/task_mappers.dart
│   │   ├── models/task_model.dart
│   │   └── repositories/task_repository_impl.dart
│   ├── pages/
│   │   ├── riverpodBack/
│   │   │   ├── task_back.dart
│   │   │   └── report_back.dart
│   │   └── screens/tasks/
│   │       ├── tasks_screen.dart
│   │       ├── add_edit_task_screen.dart
│   │       ├── colors_tasks.dart
│   │       └── widgets/tasks_widgets.dart
│   └── utils/responsive.dart
│
└── test/widget_test.dart
```

---

## Sección 1 — Ejercicios lógico-matemáticos

Los ejercicios están en un package Dart independiente (`ejercicios/`) porque al ejecutarlos desde el contexto del proyecto Flutter, el SDK intenta cargar `dart:ui` y falla. Separarlos en su propio `pubspec.yaml` resuelve el problema.

### Ejercicio 1 — Inversión de palabras

Separo la cadena por espacios, invierto cada palabra con `.reversed` sobre los caracteres, y vuelvo a unir. El orden de las palabras no cambia.

```
"Hola soy una cadena" → "aloH yos anu anedac"
```

### Ejercicio 2 — Filtrado de pares únicos

Usé un `Set<int>` como registro de elementos ya vistos. `Set.add()` devuelve `false` si el elemento ya existía, lo que me permite filtrar duplicados y pares en una sola pasada sin recorrer la lista dos veces.

```
[2, 7, 12, 33, 22, 12, 4] → [2, 12, 22, 4]
```

### Ejercicio 3 — Primos gemelos en rango

La función `esPrimo` solo comprueba divisores hasta `√n`, saltando pares. Para devolver los pares usé **Dart Records** `(int, int)` — es lo más limpio para una tupla de dos enteros sin necesidad de crear una clase.

```
[0, 10]  → (3,5) (5,7)
[100,150] → (101,103) (107,109) (137,139)
```

### Ejercicio 4 — Combinación de suma objetivo

Backtracking recursivo: en cada índice decido incluir o no el elemento y acumulo la suma. La poda `acum > objetivo` corta ramas imposibles antes de llegar al final de la lista.

```
[2, 5, 8, 44, 1, 7], objetivo 9  → true  (2+7)
[4, 8, 48, 44, 1],   objetivo 11 → false
```

### Ejercicio 5 — Consulta relacional SQLite

La consulta busca los libros de Sonia que no fueron devueltos (`Entregado = 0`) y cuya fecha de vencimiento ya pasó respecto a `'2021-07-30'`. La fecha de vencimiento la calculo directamente en SQL con `DATE(Fecha_prestamo, '+N days')`, concatenando el valor de `Dias_limite_prestamo` — así no necesito hacerlo en código.

Resultado esperado: *Estadistica* y *Desarrollo web*.

---

## Sección 2 — App Flutter

### Arquitectura

Usé una arquitectura de tres capas donde las dependencias van siempre hacia adentro:

```
Presentation  ->  Domain  <-  Infrastructure
(providers,       (Task,       (sqflite, mappers,
 screens)          repo        modelos DTO)
                 abstract)
```

La entidad `Task` es Dart puro, sin imports de Flutter. `TaskModel` es el DTO que sabe cómo mapearse a/desde SQLite — `completed` va como `INTEGER` porque SQLite no tiene booleanos. `TaskMappers` hace la conversión entre los dos. Tener esa separación hace que si en algún momento quisiera migrar de sqflite a drift, solo tendría que tocar la capa de infraestructura.

### Gestión de estado con Riverpod

Elegí `StateNotifier` sobre `AsyncNotifier` porque quería control explícito sobre cuándo el estado pasa a `loading`, `data` o `error`, y el patrón lo pedía así.

| Provider | Tipo | Para qué |
|---|---|---|
| `taskDatasourceProvider` | `Provider` | Singleton del datasource |
| `taskRepositoryProvider` | `Provider` | Inyecta el datasource al repo |
| `taskProvider` | `StateNotifierProvider` | Lista de tareas |
| `selectedTaskProvider` | `StateProvider` | Tarea en edición (null = nueva) |
| `taskJustCreatedProvider` | `StateProvider` | Señal para mostrar el modal de éxito |
| `reportProvider` | `StateNotifierProvider` | Estado del procesamiento con Isolate |

El flujo de crear una tarea es:

```
AddEditTaskScreen
  -> taskProvider.notifier.createTask()
     -> TaskRepository.createTask()
        -> TaskDatasource (sqflite INSERT)
     -> loadTasks()
        -> state = AsyncValue.data(tasks)  // UI se actualiza sola
```

**Navegación sin `extra` params:** para editar una tarea escribo la tarea en `selectedTaskProvider` antes de navegar a `/edit`, y la pantalla la lee de ahí. Así evité pasar objetos por el mecanismo `extra` de go_router, que requiere casting y puede romperse.

**Modal de éxito:** al crear una tarea activo `taskJustCreatedProvider = true` y navego directo a `/`. `TasksScreen` usa `ref.watch` sobre ese provider — no `ref.listen` — porque `listen` solo reacciona a cambios posteriores al montaje del widget, y el valor ya es `true` cuando la pantalla carga. Con `watch`, el valor inicial es leído en el primer build y el modal se agenda con `addPostFrameCallback`. Lo hice así porque mostrar un `ModalBottomSheet` desde una pantalla que se está desmontando causa un flash visual — la pantalla de formulario aparece brevemente durante la animación de cierre del modal.

### Persistencia local SQLite

Usé `sqflite` en lugar de `drift` porque el esquema es simple (una tabla, cinco columnas) y drift requiere codegen con build_runner para eso. Con sqflite escribo el SQL directamente y es más fácil de verificar.

Esquema:

```sql
CREATE TABLE tasks (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT    NOT NULL,
  description TEXT    NOT NULL,
  completed   INTEGER NOT NULL DEFAULT 0,  -- 0/1
  created_at  TEXT    NOT NULL              -- ISO 8601
)
```

El datasource usa el patrón singleton (`factory` con instancia privada) para garantizar una sola conexión abierta. La base de datos se inicializa en el primer acceso.

### Diseño responsivo

Opté por no usar `flutter_screenutil` — requiere configurar un ancho y alto de pantalla base, lo que al final son valores hardcodeados disfrazados. En su lugar hice una extensión de `BuildContext` que calcula todo a partir del lado más corto de la pantalla real del dispositivo:

```dart
double get _base => MediaQuery.sizeOf(this).shortestSide / 24;
```

De ese `_base` derivan todos los espaciados, radios y alturas. Los textos los saco directo del `TextTheme` de Material para que respeten también las preferencias de accesibilidad del sistema.

### Concurrencia con Isolates

Usé `compute()` en lugar de `Isolate.spawn()` porque solo necesito ejecutar una función y recibir un resultado — `compute()` es suficiente para eso y la API es mucho más simple.

Una restricción importante: la función que se pasa a `compute()` tiene que ser top-level o estática, no puede ser un closure. Por eso `_massiveProcessing` está definida fuera de cualquier clase.

```
Botón "Generar Reporte"
  -> reportProvider.notifier.generateReport()
     -> state = loading   // spinner aparece
     -> compute(_massiveProcessing, 100000)  // corre en hilo secundario
     -> state = done
  -> ref.listen en TasksScreen
     -> SnackBar con el resultado
```

Mientras el Isolate trabaja, el `CircularProgressIndicator` sigue animándose sin perder frames.

### Navegación

Tres rutas con go_router:

| Ruta | Pantalla |
|---|---|
| `/` | Lista de tareas |
| `/add` | Formulario — modo crear |
| `/edit` | Formulario — modo editar |

`AddEditTaskScreen` sabe si está creando o editando leyendo `selectedTaskProvider`.

### Paquetes utilizados

| Paquete | Por qué lo usé |
|---|---|
| `flutter_riverpod` | Separa la lógica de la UI sin `setState`. |
| `sqflite` | Persistencia local, API directa sobre SQLite. |
| `path` | Para calcular la ruta correcta de la BD en cada plataforma. |
| `go_router` | Navegación declarativa, más predecible que Navigator 1.0. |
| `intl` | Para mostrar las fechas en formato legible sin escribir el formato a mano. |

---

## Cómo ejecutar

**Requisitos:** Flutter SDK ≥ 3.12

### Sección 1 — Ejercicios Dart

```bash
cd ejercicios

dart run seccion1/ejercicio1.dart
dart run seccion1/ejercicio2.dart
dart run seccion1/ejercicio3.dart
dart run seccion1/ejercicio4.dart

# Ejercicio 5 — requiere sqlite3 en el PATH
# Crea una BD en memoria, ejecuta el script y muestra el resultado:
#
#   sqlite3 ":memory:" ".read seccion1/ejercicio5.sql" ".mode column" ".headers on"
#
#   sqlite3 ":memory:"                 -> BD temporal en RAM, no crea archivos
#   ".read seccion1/ejercicio5.sql"    -> ejecuta CREATE TABLE, INSERT y SELECT
#   ".mode column" ".headers on"       -> salida con columnas alineadas y encabezados
```

### Sección 2 — App Flutter

```bash
flutter pub get
flutter run

# Para correr los tests
flutter test
```

> La app es 100% offline. No requiere conexión a internet ni configuración adicional.
