CREATE DATABASE IF NOT EXISTS Insurance;
USE Insurance;

CREATE TABLE IF NOT EXISTS person (
    driver_id VARCHAR(10) NOT NULL PRIMARY KEY,
    driver_name VARCHAR(20) NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS car (
    reg_no VARCHAR(10) NOT NULL PRIMARY KEY,
    model TEXT NOT NULL,
    c_year INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS accident (
    report_no INTEGER NOT NULL PRIMARY KEY,
    accident_date DATE,
    location TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS owns (
    driver_id VARCHAR(10) NOT NULL,
    reg_no VARCHAR(10) NOT NULL,
    FOREIGN KEY(driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY(reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
    driver_id VARCHAR(10) NOT NULL,
    reg_no VARCHAR(10) NOT NULL,
    report_no INTEGER NOT NULL,
    damage_amount INTEGER NOT NULL,
    FOREIGN KEY(driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY(reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
    FOREIGN KEY(report_no) REFERENCES accident(report_no) ON DELETE CASCADE
);

INSERT INTO person VALUES
("D111", "Smith", "Kuvempunagar, Mysuru"),
("D222", "Driver_2", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Lakshmipuram, Mysuru");

INSERT INTO car VALUES
("KA20AB4223", "Mazda", 2020),
("KA20AB4224","Supra",2020),
("KA09MA1234", "WagonR", 2017),
("KA21AC5473", "Alto", 2015),
("KA21BD4728", "Triber", 2019),
("KA19CA6374", "Tiago", 2018);

INSERT INTO accident VALUES
(1, "2021-04-05", "Nazarbad, Mysuru"),
(2, "2019-12-16", "Gokulam, Mysuru"),
(3, "2020-05-14", "Bogadi, Mysuru"),
(4, "2021-08-30", "Kuvempunagar, Mysuru"),
(5, "2021-01-21", "JSS Layout, Mysuru"),
(6,"2020-09-19","Bogadi, Mysuru");

INSERT INTO owns VALUES
("D111", "KA20AB4223"),
("D111","KA20AB4224"),
("D222", "KA09MA1234"),
("D333", "KA21AC5473"),
("D444", "KA21BD4728"),
("D555", "KA19CA6374");

INSERT INTO participated VALUES
("D111", "KA20AB4223", 1, 20000),
("D222", "KA09MA1234", 2, 10000),
("D333", "KA21AC5473", 3, 15000),
("D444", "KA21BD4728", 4, 5000),
("D111","KA20AB4224",6,10000),
("D333", "KA21AC5473", 5, 25000);

SELECT * FROM person;
SELECT * FROM car;
SELECT * FROM accident;
SELECT * FROM owns;
SELECT * FROM participated;

-- QUERY 1
select count(distinct o.driver_id) as'No.of Owners'
from  owns o, participated p, accident a
where o.reg_no=p.reg_no and p.report_no=a.report_no
and year(a.accident_date)="2021";

-- QUERY 2
select count(distinct report_no) as "Accidents of Smith's cars " from participated where reg_no in
(select reg_no from owns where driver_id=(select driver_id from person where driver_name="Smith"));

-- QUERY 3
insert into accident values (7,"2023-01-02","RT Nagar, Mysuru");

-- QUERY 4
delete from car where model="Mazda" and reg_no in (select reg_no from owns where driver_id=(select driver_id from person where driver_name="Smith"));

-- QUERY 5
update participated set damage_amount=15000 where reg_no="KA09MA1234" and report_no=2;

-- VIEW 1 *
create view accidentCars as
select model, c_year from car where reg_no in (select distinct reg_no from participated);

select * from accidentCars;

-- VIEW 2
create view accOfaPlace as
select driver_name from person where driver_id in
(select driver_id from participated where report_no in
(select report_no from accident where location like "%Bogadi%"));

select * from accOfaPlace;

-- TRIGGER 1
delimiter //
create trigger rashDrivers
before insert on owns
for each row
begin
    set @total_amt=(select sum(damage_amount) from participated where driver_id=new.driver_id);
    if @total_amt > 50000 then
        signal sqlstate '50005' set message_text='Driver ineligible to own a Car!';
    end if;
end;//
delimiter ;        

-- TRIGGER 2 *
delimiter //
create trigger noMoreAccidents
before insert on participated
for each row 
begin
    set @year=(select year(accident_date) from accident where report_no=new.report_no);
    set @total_acc=(
        select count(p.report_no) 
        from participated p, accident a
        where p.report_no=a.report_no and year(a.accident_date)=@year
        and p.driver_id=new.driver_id
    );
    if @total_acc > 3 then
        signal sqlstate '52000' set message_text='Driver cannot participate in any new accidents';
    end if;
end;//
delimiter ;  
