CREATE TABLE estudiante (id SERIAL PRIMARY KEY, cedula INT UNIQUE, nombres VARCHAR, apellidos VARCHAR, direccion VARCHAR, fecha_nacimiento DATE);
CREATE TABLE materia (id SERIAL PRIMARY KEY, nombre VARCHAR);
CREATE TABLE pfg (id SERIAL PRIMARY KEY, nombre VARCHAR);
CREATE TABLE telefono (id SERIAL PRIMARY KEY, numero VARCHAR(11), id_estudiante INT REFERENCES estudiante(id) ON DELETE CASCADE);

-- Relación muchos a muchos de estudiante con pfg --
CREATE TABLE estudiante_pfg (id_estudiante INT REFERENCES estudiante(id) ON DELETE CASCADE, id_pfg INT REFERENCES pfg(id));

-- Relación muchos a muchos de materias con estudiantes
CREATE TABLE materia_estudiante (id_materia INT REFERENCES materia(id) ON DELETE CASCADE, id_estudiante INT REFERENCES estudiante(id) ON DELETE CASCADE);

-- Relación muchos a muchos de materias con pfg 
CREATE TABLE materia_pfg (id_materia INT REFERENCES materia(id), id_pfg INT REFERENCES pfg(id));

-- Tabla para almacenar a los estudiantes retirados
CREATE TABLE estudiante_retirado (id SERIAL PRIMARY KEY, cedula VARCHAR UNIQUE, nombres VARCHAR, apellidos VARCHAR, fecha DATE);

-- Insertar datos de prueba a la tabla estudiante
INSERT INTO estudiante(id, cedula, nombres, apellidos, direccion, fecha_nacimiento) VALUES
(1, 11917242, 'Jenbluk', 'Vanegas', 'Los Simbolos, Caracas.', '1978-07-12'),
(2, 5742368, 'Juan', 'Perez', 'La Bandera, Caracas.', '1989-03-24'),
(3, 18597438, 'Maria', 'Lopez', 'Plaza Venezuela, Caracas.', '1991-07-21'),
(4, 24568978, 'Ana', 'Machado', 'La Rinconada, Caracas.', '1995-01-18');

-- Hacer que la secuencia id de la tabla estudiante inicie con el valor 5
ALTER SEQUENCE estudiante_id_seq RESTART WITH 5;

-- Insertar materias de prueba
INSERT INTO materia VALUES
(1, 'Algoritmos y Programación'),
(2, 'Base de Datos'),
(3, 'Matemáticas'),
(4, 'Liderazgo Productivo');

-- Hacer que la secuencia id de la tabla materia inicie con el valor 5
ALTER SEQUENCE materia_id_seq RESTART WITH 5;

-- Insertar pfgs de prueba
INSERT INTO pfg VALUES
(0, 'Programa de Iniciación Universitaria'),
(1, 'Informática para la Gestión Social'),
(2, 'Arquitectura'),
(3, 'Gestión Ambiental');

-- Hacer que la secuencia id de la tabla pfg inicie con el valor 4
ALTER SEQUENCE pfg_id_seq RESTART WITH 4;

-- Insertar teléfonos de prueba
INSERT INTO telefono VALUES
(1, '04264567864', 1),
(2, '04125478641', 2),
(3, '04145723467', 3),
(4, '04165478782', 4);

-- Hacer que la secuencia id de la tabla telefono inicie con el valor 5
ALTER SEQUENCE telefono_id_seq RESTART WITH 5;

-- Relacionar estudiantes con pfg
INSERT INTO estudiante_pfg VALUES
(1, 1),
(2, 3),
(3, 2),
(4, 1);

-- Relacionar materias con estudiantes
INSERT INTO materia_estudiante VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(4, 2),
(4, 3),
(1, 4);

-- Relacionar materias con pfg
INSERT INTO materia_pfg VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(4, 2),
(4, 3);

-- Insertar un estudiante retirado
INSERT INTO estudiante_retirado(cedula, nombres, apellidos, fecha) VALUES (4861235, 'Pedro', 'Sanchez', '2021-11-8');

-- Vista para mostrar a todos los estudiantes con sus datos de relación de las tablas teléfono y pfg
CREATE OR REPLACE VIEW estudiante_view AS SELECT cedula,nombres,apellidos,direccion,fecha_nacimiento,numero as telefono,pfg.nombre AS PFG FROM estudiante LEFT JOIN telefono ON estudiante.id = telefono.id_estudiante LEFT JOIN estudiante_pfg ON estudiante.id = estudiante_pfg.id_estudiante LEFT JOIN pfg ON estudiante_pfg.id_pfg = pfg.id;

-- Vista para mostrar todos los pfg con sus materias
CREATE VIEW pfg_view AS SELECT pfg.nombre AS nombre_pfg, materia.nombre AS nombre_materia FROM pfg,materia_pfg,materia WHERE materia_pfg.id_pfg = pfg.id AND materia_pfg.id_materia = materia.id;

-- Vista para mostrar todos los pfg con la cantidad de estudiantes que posea
CREATE VIEW pfg_estudiante_view AS SELECT pfg.nombre AS PFG, COUNT(estudiante.cedula) AS cantidad_estudiantes FROM pfg,estudiante,estudiante_pfg WHERE estudiante.id = estudiante_pfg.id_estudiante AND pfg.id = estudiante_pfg.id_pfg GROUP BY PFG;

-- Procedimiento almacenado para inscribir estudiante en un pfg pasandole como argumento la cedula del estudiante y la id del pfg
CREATE OR REPLACE FUNCTION inscribir_estudiante_en_pfg(cedula_estudiante int, id_pfg int) RETURNS void AS $$
BEGIN
INSERT INTO estudiante_pfg(id_estudiante,id_pfg) WITH estudiante AS (SELECT id FROM estudiante WHERE estudiante.cedula = cedula_estudiante), pfg AS (SELECT id FROM pfg WHERE id = id_pfg)
select estudiante.id, pfg.id from estudiante,pfg;
END;
$$
LANGUAGE plpgsql;

-- Procedimiento almacenado para agregar numero de telefono a un estudiante, pasandole la id de estudiante y lo agrega sólo si el número de teléfono tiene 11 dígitos
CREATE OR REPLACE FUNCTION agregar_telefono_estudiante(estudiante_id int, telefono varchar) RETURNS void AS $$
BEGIN
IF (LENGTH(telefono) = 11) THEN
INSERT INTO telefono(numero,id_estudiante) VALUES (telefono, estudiante_id);
END IF;
END;
$$
LANGUAGE plpgsql;
