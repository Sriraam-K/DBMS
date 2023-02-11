CREATE DATABASE IF NOT EXISTS Enroll;
USE Enroll;

CREATE TABLE IF NOT EXISTS student (
    regno VARCHAR(20) NOT NULL PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    major VARCHAR(50) NOT NULL,
    bdate DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS course (
    c_id INTEGER NOT NULL PRIMARY KEY,
    cname VARCHAR(50) NOT NULL,
    dept VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS textbook (
    bookISBN INTEGER NOT NULL PRIMARY KEY,
    book_title VARCHAR(50) NOT NULL,
    publisher VARCHAR(50) NOT NULL,
    author VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS enroll (
    regno VARCHAR(20) NOT NULL,
    c_id INTEGER NOT NULL,
    sem INTEGER NOT NULL,
    marks INTEGER NOT NULL,
    FOREIGN KEY (regno) REFERENCES student(regno) ON DELETE CASCADE,
    FOREIGN KEY (c_id) REFERENCES course(c_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS book_adoption (
    c_id INTEGER NOT NULL,
    sem INTEGER NOT NULL,
    bookISBN INTEGER NOT NULL,
    FOREIGN KEY(bookISBN) REFERENCES textbook(bookISBN) ON DELETE CASCADE,
    FOREIGN KEY(c_id) REFERENCES course(c_id) ON DELETE CASCADE
);

INSERT INTO course VALUES
(1,"DBMS","CS"),
(2,"TOC","CS"),
(3,"Math modeling","MA"),
(4,"Sensors and actuators","EC"),
(5,"DSA","IS"),
(6,"SOM","ME"),
(7,"envi","EV");

INSERT INTO student VALUES 
("CS01","Rajat","computers","2002-05-08"),
("CS02","Ram","computers","2002-08-08"),
("EC01","Bharat","Electronics","2002-05-18"),
("EV01","Aamina","Env","2002-12-10"),
("ME01","Rudra" , "Mech" , "2002-01-24"),
("IS01","Anand","Info","2002-04-06");

INSERT INTO textbook VALUES 
(11,"Book1","pub1","auth1"),
(22,"Book2","pub1","auth2"),
(33,"Book3","pub2","auth3"),
(44,"Book4","pub3","auth4"),
(55,"Book5","pub4","auth5"),
(66,"Book6","pub5","auth6");

INSERT INTO enroll VALUES 
("CS01",1,5,70),
("CS01",2,4,90),
("CS02",2,5,80),
("CS02",1,4,70),
("EC01",4,4,60),
("CS01",4,5,76),
("ME01",6,6,60),
("EV01",7,7,57),
("IS01",5,3,90);

INSERT INTO book_adoption VALUES
(1,5,11),
(1,5,22),
(2,4,11),
(2,4,22),
(3,5,33),
(4,4,44),
(5,3,55),
(6,6,66),
(7,7,66);

SELECT * FROM student;
SELECT * FROM course;
SELECT * FROM enroll;
SELECT * FROM textbook;
SELECT * FROM book_adoption;

-- QUERY 1


-- QUERY 2
select c.c_id, t.bookISBN, t.book_title from course c, textbook t, book_adoption b
where c.c_id=b.c_id and t.bookISBN=b.bookISBN and c.dept="CS"
and (select count(*) from book_adoption where b.c_id=c.c_id) >= 2
order by c.cname;

-- QUERY 3
select dept from course
natural join book_adoption
natural join textbook
where publisher in (select publisher from textbook)
group by dept;
-- or
select dept from course
natural join book_adoption
natural join textbook
where publisher = "pub1"
group by dept;

-- QUERY 4
select s.sname from student s, enroll e, course c
where s.regno=e.regno and c.c_id=e.c_id and e.marks=(select max(marks) from enroll e, course c 
where c.c_id=e.c_id and c.cname="DBMS");

-- TRIGGER 1
delimiter //
create trigger unenroll
before insert on enroll
for each row
begin
    if new.marks < 50 then
        signal sqlstate '45001' set message_text='Student not eligible to take up the course';
    end if;
end;//
delimiter ;        

