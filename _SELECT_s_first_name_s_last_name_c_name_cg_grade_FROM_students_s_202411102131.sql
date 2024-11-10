INSERT INTO "SELECT s.first_name, s.last_name, c.name, cg.grade
FROM students s
JOIN course_grades cg ON s.id = cg.student_id
JOIN courses c ON cg.course_id = c.id
WHERE c.name = 'Математика' AND cg.grade > 80" (first_name,last_name,"name",grade) VALUES
	 ('Иван','Иванов','Математика',85),
	 ('Анна','Смирнова','Математика',92);
