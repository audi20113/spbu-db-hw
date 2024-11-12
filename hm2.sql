-- Создание таблицы student_courses
CREATE TABLE student_courses (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    course_id INTEGER REFERENCES courses(id),
    UNIQUE (student_id, course_id)
);

select * from student_courses;

-- Заполнение таблицы student_courses данными
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 3), (2, 4),
(3, 2), (3, 3),
(4, 1), (4, 4),
(5, 2), (5, 4);


--Создание таблицы group_courses
CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(id),
    course_id INTEGER REFERENCES courses(id),
    UNIQUE (group_id, course_id)
);

-- Заполняем таблицу group_courses данными
INSERT INTO group_courses (group_id, course_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 2),
(2, 4);

select * from group_courses;


--Удаление неактуальных полей
ALTER TABLE students
DROP COLUMN courses_ids;

select * from students;

--Добавление уникального ограничения и индекса
ALTER TABLE courses
ADD CONSTRAINT unique_course_name UNIQUE (name);


--Создание индекса на поле group_id в таблице students
CREATE INDEX idx_students_group_id ON students(group_id);


--Список всех студентов с их курсами
SELECT s.first_name, s.last_name, c.name AS course_name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id
ORDER BY s.id;


--Найти студентов, у которых средняя оценка выше, чем у любого другого студента в их группе
WITH student_avg_grades AS (
    SELECT s.id AS student_id, s.group_id, AVG(cg.grade) AS avg_grade
    FROM students s
    JOIN course_grades cg ON s.id = cg.student_id
    GROUP BY s.id, s.group_id
)
SELECT s.first_name, s.last_name, g.full_name AS group_name, sa.avg_grade
FROM student_avg_grades sa
JOIN students s ON s.id = sa.student_id
JOIN groups g ON s.group_id = g.id
WHERE sa.avg_grade > (
    SELECT MAX(sa2.avg_grade)
    FROM student_avg_grades sa2
    WHERE sa2.group_id = s.group_id AND sa2.student_id != s.id
);


--Подсчитать количество студентов на каждом курсе
SELECT c.name AS course_name, COUNT(sc.student_id) AS student_count
FROM courses c
LEFT JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.id;

--Найти среднюю оценку на каждом курсе
SELECT c.name AS course_name, AVG(cg.grade) AS average_grade
FROM courses c
JOIN course_grades cg ON c.id = cg.course_id
GROUP BY c.id;



