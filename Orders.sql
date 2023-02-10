CREATE DATABASE IF NOT EXISTS Orders;
USE Orders;

CREATE TABLE IF NOT EXISTS customer (
    cust VARCHAR(10) NOT NULL PRIMARY KEY,
    cname VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    oid INTEGER NOT NULL PRIMARY KEY,
    odate DATE NOT NULL,
    cust VARCHAR(10) NOT NULL,
    order_amt INTEGER DEFAULT 0,
    FOREIGN KEY(cust) REFERENCES customer(cust) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS warehouse (
    wid VARCHAR(10) NOT NULL PRIMARY KEY,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS item (
    itemid VARCHAR(10) NOT NULL PRIMARY KEY,
    unitprice INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS order_item (
    oid INTEGER NOT NULL,
    itemid VARCHAR(10) NOT NULL,
    qty INTEGER NOT NULL,
    FOREIGN KEY(oid) REFERENCES orders(oid) ON DELETE CASCADE,
    FOREIGN KEY(itemid) REFERENCES item(itemid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shipment (
    oid INTEGER NOT NULL,
    wid VARCHAR(10) NOT NULL,
    ship_date DATE NOT NULL,
    FOREIGN KEY(oid) REFERENCES orders(oid) ON DELETE CASCADE,
    FOREIGN KEY(wid) REFERENCES warehouse(wid) ON DELETE CASCADE
);

INSERT INTO customer VALUES
("c1", "Kumar", "Mysuru"),
("c2", "Customer_2", "Bengaluru"),
("c3", "Customer_3", "Mumbai"),
("c4", "Customer_4", "Dehli"),
("c5", "Customer_5", "Bengaluru");

INSERT INTO orders VALUES
(001, "2020-01-14", "c1", 2000),
(002, "2021-04-13", "c1", 500),
(003, "2019-10-02", "c2", 2500),
(004, "2019-05-12", "c3", 1000),
(005, "2020-12-23", "c4", 1200);

INSERT INTO item VALUES
("i1", 400),
("i2", 200),
("i3", 1000),
("i4", 100),
("i5", 500);

INSERT INTO warehouse VALUES
("w1", "Mysuru"),
("w2", "Bengaluru"),
("w3", "Mumbai"),
("w4", "Delhi"),
("w5", "Chennai");

INSERT INTO order_item VALUES 
(001, "i1", 5),
(002, "i5", 1),
(003, "i5", 5),
(004, "i3", 1),
(005, "i4", 12);

INSERT INTO shipment VALUES
(001, "w2", "2020-01-16"),
(002, "w1", "2021-04-14"),
(003, "w2", "2019-10-07"),
(004, "w3", "2019-05-16"),
(005, "w5", "2020-12-23");

-- QUERY 1
select oid, ship_date from shipment where wid="w2";

-- QUERY 2
select s.oid, s.wid 
from shipment s, orders o, customer c
where s.oid=o.oid and o.cust=c.cust and c.cname="Kumar"; 

-- QUERY 3
select c.cname, count(o.oid) as 'No.of Orders', avg(o.order_amt) as 'Average amt'
from customer c, orders o
where c.cust=o.cust
group by c.cust;

-- QUERY 4
delete from orders where cust=(select cust from customer where cname="Kumar");

-- QUERY 5
select * from item where unitprice=(select max(unitprice) from item);

-- VIEW 1 *
create view ordersofw2 as
select oid, ship_date from shipment where wid="w5";

select * from ordersofw2;

-- VIEW 2
create view kumarWare as
select s.oid, s.wid 
from shipment s, orders o, customer c
where s.oid=o.oid and o.cust=c.cust and c.cname="Kumar";

select * from kumarWare;

-- TRIGGER 1 *
delimiter //
create trigger billItem
after insert on order_item
for each row
begin
    set @old=(select order_amt from orders where oid=new.oid);
    set @iamt=(select unitprice from item where itemid=new.itemid);
    update orders set order_amt=@old+(new.qty*@iamt) where oid=new.oid;
end;//
delimiter ;