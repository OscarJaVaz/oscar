-- Ejercicio 5 - Sección 1: Consulta relacional (SQL / SQLite)


CREATE TABLE IF NOT EXISTS ALUMNO (
    id         INTEGER PRIMARY KEY,
    Nombres    TEXT NOT NULL,
    Apellidos  TEXT NOT NULL,
    Carrera    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS LIBRO (
    id                   INTEGER PRIMARY KEY,
    Nombre               TEXT NOT NULL,
    Editorial            TEXT NOT NULL,
    Dias_limite_prestamo INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS PRESTAMO (
    id              INTEGER PRIMARY KEY,
    Id_alumno       INTEGER NOT NULL REFERENCES ALUMNO(id),
    Id_libro        INTEGER NOT NULL REFERENCES LIBRO(id),
    Fecha_prestamo  TEXT    NOT NULL,
    Entregado       INTEGER NOT NULL
);




INSERT INTO ALUMNO (id, Nombres, Apellidos, Carrera) VALUES
    (1, 'Rosa',  'Torres', 'Sistemas'),
    (2, 'Angel', 'Perez',  'Electronica'),
    (3, 'Sonia', 'Ríos',   'Industrial');

INSERT INTO LIBRO (id, Nombre, Editorial, Dias_limite_prestamo) VALUES
    (1, 'Administración',    'Norma',      30),
    (2, 'Redes neuronales',  'Santillana', 30),
    (3, 'Estadistica',       'Regio',      10),
    (4, 'Desarrollo web',    'Limusa',     10);

INSERT INTO PRESTAMO (id, Id_alumno, Id_libro, Fecha_prestamo, Entregado) VALUES
    (1,  1, 1, '2021-07-23', 0),
    (2,  1, 2, '2021-07-22', 0),
    (3,  1, 3, '2021-06-15', 0),
    (4,  2, 1, '2021-07-12', 0),
    (5,  3, 1, '2021-07-28', 1),
    (6,  3, 2, '2021-07-16', 1),
    (7,  3, 3, '2021-07-28', 1),
    (8,  3, 4, '2021-05-10', 0),
    (9,  2, 2, '2021-07-28', 0),
    (10, 3, 2, '2021-04-05', 0);




SELECT
    L.Nombre              AS Libro,
    L.Editorial,
    P.Fecha_prestamo,
    DATE(P.Fecha_prestamo, '+' || L.Dias_limite_prestamo || ' days')
                          AS Fecha_vencimiento
FROM  PRESTAMO P
INNER JOIN ALUMNO A ON P.Id_alumno = A.id
INNER JOIN LIBRO  L ON P.Id_libro  = L.id
WHERE A.Nombres   = 'Sonia'
  AND P.Entregado = 0
  AND DATE(P.Fecha_prestamo, '+' || L.Dias_limite_prestamo || ' days') < '2021-07-30';

--para correr el ejercicio en la terminal ejecutar el comando: cd ejercicios && sqlite3 ":memory:" ".read seccion1/ejercicio5.sql" ".mode column" ".headers on"