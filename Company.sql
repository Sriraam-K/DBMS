CREATE DATABASE IF NOT EXISTS Company;
USE Company;

CREATE TABLE IF NOT EXISTS department (
    dno INTEGER NOT NULL PRIMARY KEY,
    dname VARCHAR(50) NOT NULL,
    mgrssn VARCHAR(20),
    mgrstartdate DATE 
);

CREATE TABLE IF NOT EXISTS employee (
    ssn VARCHAR(20) PRIMARY KEY,
    ename VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    sex VARCHAR(10) NOT NULL,
    salary INTEGER NOT NULL,
    superssn VARCHAR(20),
    dno INTEGER NOT NULL,
    FOREIGN KEY(dno) REFERENCES department(dno) ON DELETE CASCADE,
    FOREIGN KEY(superssn) REFERENCES employee(ssn) ON DELETE SET NULL 
);

CREATE TABLE IF NOT EXISTS dlocation (
    dno INTEGER NOT NULL,
    dloc TEXT,
    FOREIGN KEY(dno) REFERENCES department(dno) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS project (
    pno INTEGER NOT NULL PRIMARY KEY,
    pname VARCHAR(50),
    ploc TEXT NOT NULL,
    dno INTEGER NOT NULL,
    FOREIGN KEY(dno) REFERENCES department(dno) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS works_on (
    ssn VARCHAR(20) ,
    pno INTEGER NOT NULL,
    hour INTEGER NOT NULL,
    FOREIGN KEY(ssn) REFERENCES employee(ssn) ON DELETE CASCADE,
    FOREIGN KEY(pno) REFERENCES project(pno) ON DELETE CASCADE
);

INSERT INTO DEPARTMENT VALUES 
(1,"ACCOUNTS","RNSACC01","2018-09-12"),
(2,"IT","RNSIT01","2020-06-08"),
(3,"ECE","RNSECE01","2020-05-14"),
(4,"IP","RNSIP01","2020-09-21"),
(5,"CSE","RNSCSE01","2020-03-25");

INSERT INTO EMPLOYEE VALUES
("RNSECE01","JOHN SCOTT","Bengaluru","M", 450000,NULL,3),
("RNSCSE01","JAMES SMITH","Bengaluru","M", 500000,NULL,5),
("RNSCSE02","HEARN BAKER","Bengaluru","M", 370000,"RNSCSE01",5),
("RNSCSE03","EDWARD SCOTT","Mysuru","M", 700000,"RNSCSE01",5),
("RNSCSE04","PAVAN KULKARNI","Mangaluru","M", 650000,"RNSCSE01",5),
("RNSCSE05","KRITHI SHETTY","Mangaluru","F",250000,"RNSCSE01",5),
("RNSCSE06","TANISHA PATEL","Mysuru","F",350000,"RNSCSE01",5),
("RNSACC01","AHANA K","Mangaluru","F", 350000,NULL,1),
("RNSACC02","SANTHOSH KUMAR","Mangaluru","M", 300000,"RNSACC01",1),
("RNSIP01","VINOD SHARMA","Mysuru","M", 200000,NULL,4),
("RNSIT01","SUKESH HEGDE","Mysuru","M", 145000,NULL,5),
("RNSIT02","NIHARIKA SN","Bengaluru","F", 80000,"RNSIT01",5),
("RNSIT03","NAGESH HR","Bengaluru","M", 50000,"RNSIT01",2);

INSERT INTO DLOCATION VALUES 
(1,'Mysuru'),
(2,'Bengaluru'),
(3,'Pune'),
(4,'Hyderabad'),
(5,'Bengaluru'),
(5,'Mumbai');

INSERT INTO PROJECT VALUES 
(101,'IOT','Bengaluru',5),
(102,'SILICON MINING','Nellore',4),
(103,'BIGDATA','Mumbai',5),
(104,'SENSORS','Pune',3),
(105,'BANK MANAGEMENT','Mysuru',1),
(106,'SALARY MANAGEMENT','Mysuru',1),
(107,'OPENSTACK','Bengaluru',2),
(108,'SMART CITY','Bengaluru',2);

INSERT INTO WORKS_ON VALUES 
('RNSCSE01', 101 ,8),
('RNSCSE02', 101 ,8),
('RNSCSE03', 101 ,6),
('RNSCSE04', 103 ,6),
('RNSCSE05', 103 ,8),
('RNSCSE06', 103 ,8),
('RNSCSE03', 103 ,4),
('RNSCSE04', 101 ,4),
('RNSECE01', 104 ,10),
('RNSACC01', 105 ,6),
('RNSACC02', 106 ,6),
('RNSIP01', 102 ,12),
('RNSIT01', 107 ,8),
('RNSIT01', 107 ,8),
('RNSIT01', 108 ,10);

alter table department add foreign key(mgrssn) references employee(ssn);

SELECT * FROM department ;
SELECT * FROM employee;
SELECT * FROM dlocation;
SELECT * FROM project;
SELECT * FROM works_on;


-- QUERY 1
(select distinct p.pno as 'PROJECT IDs'
from project p, department d, employee e
where p.dno=d.dno
and d.mgrssn=e.ssn
and e.ename like '%Scott')
union
(select distinct p.pno
from project p, works_on w, employee e
where p.pno=w.pno
and e.ssn=w.ssn
and e.ename like '%Scott');

-- QUERY 2
select e.ename as Name, 1.1*e.salary as 'New Salary'
from employee e, works_on w, project p
where e.ssn=w.ssn
and w.pno=p.pno
and p.pname='IOT';

-- QUERY 3
select sum(salary), max(salary), min(salary), avg(salary)
from employee, department
where employee.dno=department.dno
and department.dname='ACCOUNTS';

-- QUERY 4
select e.ename as Name
from employee e
where not exists(
(select p.pno from project p where p.dno=5 and 
not exists 
(select w.pno from works_on w where e.ssn=w.ssn and w.pno=p.pno)));

-- QUERY 5
select d.dno, count(*) as 'No.of employees'
from department d, employee e
where d.dno=e.dno
and e.salary>600000
and d.dno in (select e.dno
from employee e
group by e.dno
having count(*)>5)
group by d.dno;

-- VIEW 1 *
create view empadd as
select e.ename, d.dname ,e.address as location
from employee e, department d
where e.dno=d.dno;

select * from empadd;

-- VIEW 2
create view projectloc as
select p.pname, p.ploc, d.dname
from project p, department d
where p.dno=d.dno;

select * from projectloc;

-- TRIGGER 1
delimiter //
create trigger setMgrdate 
before update on department
for each row
begin
    if new.mgrssn!=null then
        set new.mgrstartdate=curdate();
    else
        set new.mgrstartdate=null;    
    end if;    
end;//
delimiter ;

-- TRIGGER 2 *
delimiter //
create trigger activeProject
before delete on project
for each row
begin
    if old.pno in (select pno from works_on) then
        signal sqlstate '54000' set message_text='Project under Progress. Deletion not permitted';
    end if;
end;//
delimiter ;    