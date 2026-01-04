# Create student database. 
CREATE DATABASE student_database; 
USE student_database; 
#____________________________________________________________________________________________#
# Create table that has all the attributes of a student. We have a student's ID, Full Name, Age, Gender, Grade, Attendance 
# in percentage and GPA.  
CREATE TABLE student(
	Student_ID INT PRIMARY KEY AUTO_INCREMENT,
    Student_Name VARCHAR(30) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Grade_Level INT NOT NULL,
    Attendance INT NOT NULL,
    GPA DECIMAL(3, 2) NOT NULL
);

