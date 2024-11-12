-- Создаем таблицу для курсов
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    is_exam BOOLEAN DEFAULT FALSE,
    min_grade INTEGER CHECK (min_grade >= 0),
    max_grade INTEGER CHECK (max_grade <= 100)
);

-- Создаем таблицу для групп
CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    short_name VARCHAR(50) NOT NULL,
    students_ids INTEGER[]
);

-- Создаем таблицу для студентов
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    group_id INTEGER REFERENCES groups(id),
    courses_ids INTEGER[]
);

-- Создаем таблицу для оценок по курсу
CREATE TABLE course_grades (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    course_id INTEGER REFERENCES courses(id),
    grade INTEGER CHECK (grade >= 0 AND grade <= 100),
    grade_str VARCHAR(10)
);


-- Заполняем таблицу courses
INSERT INTO courses (name, is_exam, min_grade, max_grade)
VALUES 
('Математика', TRUE, 50, 100),
('Физика', TRUE, 40, 100),
('История', FALSE, 60, 100),
('Информатика', TRUE, 70, 100);

-- Заполняем таблицу groups
INSERT INTO groups (full_name, short_name, students_ids)
VALUES 
('Группа А', 'ИнжА', ARRAY[1, 2, 3]),
('Группа Б', 'НаучБ', ARRAY[4, 5]);

-- Заполняем таблицу students
INSERT INTO students (first_name, last_name, group_id, courses_ids)
VALUES 
('Иван', 'Иванов', 1, ARRAY[1, 2]),
('Анна', 'Смирнова', 1, ARRAY[1, 3, 4]),
('Борис', 'Петров', 1, ARRAY[2, 3]),
('Екатерина', 'Кузнецова', 2, ARRAY[1, 4]),
('Дмитрий', 'Соколов', 2, ARRAY[2, 4]);

-- Заполняем таблицу course_grades
INSERT INTO course_grades (student_id, course_id, grade, grade_str)
VALUES
(1, 1, 85, 'Отлично'),
(1, 2, 78, 'Хорошо'),
(2, 1, 92, 'Отлично'),
(2, 4, 88, 'Хорошо'),
(3, 2, 65, 'Удовл.'),
(4, 1, 74, 'Хорошо'),
(5, 2, 59, 'Плохо'),
(5, 4, 91, 'Отлично');

SELECT * FROM course_grades;

-- Фильтрация данных

--Выбрать всех студентов, у которых оценка выше 80 по курсу Математика
SELECT s.first_name, s.last_name, c.name, cg.grade
FROM students s
JOIN course_grades cg ON s.id = cg.student_id
JOIN courses c ON cg.course_id = c.id
WHERE c.name = 'Математика' AND cg.grade > 80;

--Выбрать всех студентов из группы Б
SELECT s.first_name, s.last_name
FROM students s
JOIN groups g ON s.group_id = g.id
WHERE g.short_name = 'НаучБ';

-- Агрегация данных

-- Подсчитать количество студентов в каждой группе
SELECT g.full_name, COUNT(s.id) AS student_count
FROM groups g
LEFT JOIN students s ON g.id = s.group_id
GROUP BY g.full_name;

-- Подсчитать количество студентов, получивших оценку выше 70
SELECT COUNT(*) AS students_above_70
FROM course_grades
WHERE grade > 70;


