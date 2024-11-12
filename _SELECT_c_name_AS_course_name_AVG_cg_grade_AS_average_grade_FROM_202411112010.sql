INSERT INTO "SELECT c.name AS course_name, AVG(cg.grade) AS average_grade
FROM courses c
JOIN course_grades cg ON c.id = cg.course_id
GROUP BY c.id
" (course_name,average_grade) VALUES
	 ('Математика',83.6666666666666667),
	 ('Информатика',89.5000000000000000),
	 ('Физика',67.3333333333333333);
