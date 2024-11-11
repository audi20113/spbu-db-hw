INSERT INTO "WITH student_avg_grades AS (
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
)
" (first_name,last_name,group_name,avg_grade) VALUES
	 ('Дмитрий','Соколов','Группа Б',75.0000000000000000),
	 ('Анна','Смирнова','Группа А',90.0000000000000000);
