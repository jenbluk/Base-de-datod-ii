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

-- Disparador para ingresar a los estudiantes nuevo al Programa de Iniciación Universitaria cuando se registre un nuevo estudiante en la tabla estudiante
CREATE FUNCTION inscribir_piu() RETURNS TRIGGER AS $$
BEGIN
INSERT INTO estudiante_pfg(id_estudiante,id_pfg) VALUES(NEW.id, 0);
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_inscribir_piu AFTER INSERT ON estudiante FOR EACH ROW EXECUTE PROCEDURE inscribir_piu();

-- Disparador para que al eliminar un registro de la tabla estudiante se inserte sus datos en la tabla estudiante_retirado con la fecha en que se eliminó
CREATE FUNCTION retirar_estudiante() RETURNS TRIGGER AS $$
BEGIN
INSERT INTO estudiante_retirado(cedula,nombres,apellidos,fecha) VALUES (OLD.cedula, OLD.nombres, OLD.apellidos, now());
RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER retirar_estudiante_trigger BEFORE DELETE ON estudiante FOR EACH ROW EXECUTE PROCEDURE retirar_estudiante();

-- Disparador para cuando se agregue un nuevo pfg se le ingrese la materia obligatoria Liderazgo Productivo que deben llevar todos los pfg
CREATE FUNCTION materia_obligatoria() RETURNS TRIGGER AS $$
BEGIN
INSERT INTO materia_pfg VALUES (4, NEW.id);
RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER materia_obligatoria_trigger AFTER INSERT ON pfg FOR EACH ROW EXECUTE PROCEDURE materia_obligatoria();
