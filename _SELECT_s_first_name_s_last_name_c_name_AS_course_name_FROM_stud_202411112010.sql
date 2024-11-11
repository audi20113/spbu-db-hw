INSERT INTO "SELECT s.first_name, s.last_name, c.name AS course_name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id
ORDER BY s.id
" (first_name,last_name,course_name) VALUES
	 ('Иван','Иванов','Математика'),
	 ('Иван','Иванов','Физика'),
	 ('Анна','Смирнова','Математика'),
	 ('Анна','Смирнова','История'),
	 ('Анна','Смирнова','Информатика'),
	 ('Борис','Петров','Физика'),
	 ('Борис','Петров','История'),
	 ('Екатерина','Кузнецова','Математика'),
	 ('Екатерина','Кузнецова','Информатика'),
	 ('Дмитрий','Соколов','Физика');
INSERT INTO "SELECT s.first_name, s.last_name, c.name AS course_name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id
ORDER BY s.id
" (first_name,last_name,course_name) VALUES
	 ('Дмитрий','Соколов','Информатика');
