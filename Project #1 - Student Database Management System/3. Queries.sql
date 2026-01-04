# Section A. Level 1 Questions:

#1. Get the data of all the students in the school: 
SELECT * FROM student; 

# 2. Want to get the information of a specific student. 
# Use stored procedure.
DELIMITER $$ 
CREATE PROCEDURE find_student(IN id INT)
BEGIN
	SELECT * FROM student
    WHERE student_id = id;
END $$
DELIMITER ;

# Now to get the information of a specific student, all we need to do to is call the stored procedure and
# pass the student's student_ID as an arguement. For example, lets find the information of student #50. 
CALL find_student(50);

#3. Find the total number of students in the school:
SELECT COUNT(student_ID) FROM student;

#4. Find the average GPA of all students:
SELECT AVG(gpa) FROM student; 

#5. Want to find all students will low GPAs i.e less than 2.5:
SELECT student_id, student_name, grade_level, gpa  
FROM student
WHERE GPA < 2.5; 

#6. Want to find all students will low attendance e i.e less than 80%:
SELECT student_id, student_name, grade_level, attendance 
FROM student
WHERE Attendance < 80;

#7. Want to find all students with high GPAs.
SELECT student_id, student_name, grade_level, gpa  
FROM student
WHERE GPA > 3.7; 

#8. Want to find students with high attendance.
SELECT student_id, student_name, grade_level, attendance 
FROM student
WHERE Attendance > 90;

#9. Which students have a low GPA and low attendance.
SELECT student_id, student_name, grade_level, gpa, attendance
FROM student
WHERE GPA < 2.5 AND Attendance < 80;

#10. Want to see how many males and females attend the schoo.
SELECT COUNT(student_id) AS "Total Number of Students", gender
FROM student
GROUP BY gender;

# Section B. Level 2 Questions:

#1. Show how many students are in each grade level. 
SELECT grade_level, COUNT(student_ID) AS "Total Number of Students."
FROM student
GROUP BY grade_level
ORDER BY grade_level;

#2. Show the average GPA of students in each grade level. 
SELECT grade_level, AVG(GPA) AS "Average GPA."
FROM student
GROUP BY grade_level
ORDER BY grade_level;

#3. Find average attendance of students in each grade level.
SELECT grade_level, AVG(attendance) AS "Average Attendance"
FROM student
GROUP BY grade_level
ORDER BY grade_level;

#4. Find which students have a GPA higher than the average. 
SELECT student_ID, student_name, grade_level, gpa
FROM student 
WHERE gpa > (SELECT AVG(GPA) FROM student);

#5. Find which students have a GPA higher than the average of their grade level. 
SELECT student_ID, student_name, grade_level, gpa
FROM student as a
WHERE a.gpa > (SELECT AVG(GPA) FROM student WHERE grade_level = a.grade_level);

#6. Make an honor roll list. 
SELECT student_Name, gpa, grade_level
FROM student 
WHERE gpa > 3.7 AND attendance > 90
ORDER BY grade_level; 










