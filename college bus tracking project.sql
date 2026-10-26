-- ===================================================================
--  COLLEGE BUS TRACKING SYSTEM |  END-TO-END MYSQL PROJECT
-- =====================================================================
--  Contents:
--    PART 1  : Database & Table Creation (schema)
--    PART 2  : Sample Data (INSERT statements)
--    PART 3  : Indexes
--    PART 4  : Views
--    PART 5  : Stored Procedures
--    PART 6  : Triggers (+ supporting stock_log table)
--    PART 7  : Query Bank - Level 1 (Original Q1-Q4)   + Answers
--    PART 8  : Query Bank - Level 2 (Original Q5-Q8)   + Answers
--    PART 9  : Query Bank - Level 3 (Original Q9-Q11)  + Answers
--    PART 10 : Query Bank - New Queries (Q12-Q21)      + Answers
--    PART 11 : Demo calls for Views / Procedures / Triggers
--
--  RDBMS   : MySQL 8.0+ (also compatible with MariaDB 10.x)
--  Notes   : Every ANSWER below each query is a comment showing what
--            that query returns when run against the sample data in
--            PART 2. Run the SELECT yourself to confirm.
-- =====================================================================
-- NOTE:
-- This project manages bus records, assignments, routes, and schedules.
-- It does NOT provide live GPS tracking without a GPS device/application.
-- Run this script in MySQL Workbench.
-- =====================================================================

-- =====================================================================
-- PART 1: DATABASE & TABLE CREATION
-- =================================================================
drop database if exists college_bus_tracking;
create database college_bus_tracking;
use college_bus_tracking;

--  DRIVERS
CREATE TABLE drivers (
    driver_id   INT AUTO_INCREMENT PRIMARY KEY,
    driver_name VARCHAR(100) NOT NULL,
    phone       VARCHAR(15),
    license_no  VARCHAR(30) UNIQUE NOT NULL);

--  ROUTES
CREATE TABLE routes (
    route_id      INT AUTO_INCREMENT PRIMARY KEY,
    route_name    VARCHAR(100) NOT NULL,
    start_location VARCHAR(100),
    end_location  VARCHAR(100),
    distance      DECIMAL(6,2));

--  BUSES
CREATE TABLE buses (
    bus_id     INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(20) UNIQUE NOT NULL,
    capacity   INT NOT NULL,
    route_id   INT,
    CONSTRAINT fk_buses_route FOREIGN KEY (route_id) REFERENCES routes(route_id));

--  TRIPS
CREATE TABLE trips (
    trip_id    INT AUTO_INCREMENT PRIMARY KEY,
    trip_date  DATE NOT NULL,
    start_time TIME,
    end_time   TIME,
    status     VARCHAR(20) DEFAULT 'Scheduled',
    driver_id  INT NOT NULL,
    bus_id     INT NOT NULL,
    CONSTRAINT fk_trips_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT fk_trips_bus    FOREIGN KEY (bus_id)    REFERENCES buses(bus_id));

--  BUS_TRACKING
CREATE TABLE bus_tracking (
    tracking_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id     INT NOT NULL,
    latitude    DECIMAL(9,6) NOT NULL,
    longitude   DECIMAL(9,6) NOT NULL,
    recorded_at DATETIME NOT NULL,
    CONSTRAINT fk_tracking_trip FOREIGN KEY (trip_id) REFERENCES trips(trip_id));
    
--  CUSTOMERS
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100),           -- derived/optional
    phone       VARCHAR(15),
    city        VARCHAR(50),
    join_date   DATE DEFAULT (CURRENT_DATE));

--  STUDENTS
CREATE TABLE students (
    student_id   INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department   VARCHAR(50),
    phone        VARCHAR(15));

--  BUS_STOPS
CREATE TABLE bus_stops (
    stop_id    INT AUTO_INCREMENT PRIMARY KEY,
    route_id   INT NOT NULL,
    stop_name  VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL,
    CONSTRAINT fk_stops_route FOREIGN KEY (route_id) REFERENCES routes(route_id));

--  STUDENT_BUS
CREATE TABLE student_bus (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL,
    bus_id        INT NOT NULL,
    stop_id       INT NOT NULL,
    assigned_date DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_sb_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_sb_bus     FOREIGN KEY (bus_id)     REFERENCES buses(bus_id),
    CONSTRAINT fk_sb_stop    FOREIGN KEY (stop_id)    REFERENCES bus_stops(stop_id));

--  ORDERS
CREATE TABLE orders (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id  INT NOT NULL,
    student_id   INT NOT NULL,   -- 'assigned to' relationship
    bus_id       INT NOT NULL,   -- 'has' relationship
    order_date   DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(30),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_student  FOREIGN KEY (student_id)  REFERENCES students(student_id),
    CONSTRAINT fk_orders_bus      FOREIGN KEY (bus_id)      REFERENCES buses(bus_id));

--  ORDER_DETAILS
CREATE TABLE order_details (
    detail_id             INT AUTO_INCREMENT PRIMARY KEY,
    order_id              INT NOT NULL,
    quantity_ordered      INT NOT NULL,
    price_at_time_of_order DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_od_order FOREIGN KEY (order_id) REFERENCES orders(order_id));

--  ATTENDANCE
CREATE TABLE attendance (
    student_id     INT NOT NULL,
    trip_id        INT NOT NULL,
    boarding_time  TIME,
    status         VARCHAR(20) DEFAULT 'Present',
    attendance_date DATE NOT NULL,
    PRIMARY KEY (student_id, trip_id, attendance_date),
    CONSTRAINT fk_att_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_att_trip    FOREIGN KEY (trip_id)    REFERENCES trips(trip_id));

--  COMPLAINTS
CREATE TABLE complaints (
    complaint_id   INT AUTO_INCREMENT PRIMARY KEY,
    student_id     INT NOT NULL,
    bus_id         INT NOT NULL,
    complaint_text VARCHAR(255),
    complaint_date DATE DEFAULT (CURRENT_DATE),
    status         VARCHAR(20) DEFAULT 'Open',
    CONSTRAINT fk_comp_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_comp_bus     FOREIGN KEY (bus_id)     REFERENCES buses(bus_id));

-- Create a refund table
CREATE TABLE IF NOT EXISTS bus_refunds (
    refund_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    dropout_date DATE NOT NULL,
    refund_due_date DATE NOT NULL,
    refund_status VARCHAR(20) DEFAULT 'Pending');
    
    -- create a bus_assignment_audit
    CREATE TABLE IF NOT EXISTS bus_assignment_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    bus_id INT,
    action_type VARCHAR(20),
    action_date DATETIME DEFAULT CURRENT_TIMESTAMP);
    
	-- refund_status_audit
    CREATE TABLE IF NOT EXISTS refund_status_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    refund_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP);
    
    -- complaint_audit
    CREATE TABLE IF NOT EXISTS complaint_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT,
    student_id INT,
    action_type VARCHAR(30),
    action_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
DESC complaint_audit;
    
-- =====================================================================
-- PART 2: SAMPLE DATA
-- =====================================================================
  -- DRIVERS
INSERT INTO drivers (driver_name, phone, license_no) VALUES
('Ravi Kumar',   '9876543210', 'DL-AP-1001'),
('Suresh Babu',  '9876500011', 'DL-AP-1002'),
('Anil Reddy',   '9876500022', 'DL-TS-1003'),
('Mahesh Goud',  '9876500033', 'DL-TS-1004'),
('Vijay Kumar',  '9876500044', 'DL-AP-1005'),
('Ramesh Yadav', '9876500055', 'DL-AP-1006'),
('Prakash Rao',  '9876500066', 'DL-TS-1007'),
('Naresh Naidu', '9876500077', 'DL-AP-1008'),
('Srinivas Rao', '9876500088', 'DL-TS-1009'),
('Gopal Krishna','9876500099', 'DL-AP-1010');

-- ROUTES 
INSERT INTO routes (route_name, start_location, end_location, distance) VALUES
('Route A - Campus Express', 'Gachibowli',     'College Main Gate', 12.50),
('Route B - City Loop',      'Secunderabad',   'College Main Gate', 18.20),
('Route C - Suburban',       'Miyapur',        'College Main Gate', 22.00),
('Route D - Old City',       'Charminar',      'College Main Gate', 25.40),
('Route E - Airport Road',   'Shamshabad',     'College Main Gate', 30.10),
('Route F - North Zone',     'Kompally',       'College Main Gate', 20.75),
('Route G - West Zone',      'Lingampally',    'College Main Gate', 16.30),
('Route H - East Zone',      'Uppal',          'College Main Gate', 19.90),
('Route I - South Zone',     'LB Nagar',       'College Main Gate', 21.60),
('Route J - Central',        'Ameerpet',       'College Main Gate', 14.80);

-- BUSES 
INSERT INTO buses (bus_number, capacity, route_id) VALUES
('AP09AB1234', 50, 1),
('AP09CD5678', 45, 2),
('TS10EF9012', 40, 3),
('AP09GH3456', 55, 4),
('TS10IJ7890', 48, 5),
('AP09KL2345', 42, 6),
('TS10MN6789', 50, 7),
('AP09OP1122', 46, 8),
('TS10QR3344', 44, 9),
('AP09ST5566', 52, 10);

-- TRIPS 
INSERT INTO trips (trip_date, start_time, end_time, status, driver_id, bus_id) VALUES
('2026-09-18', '07:30:00', '08:45:00', 'Completed', 1, 1),
('2026-09-18', '08:00:00', '09:15:00', 'Completed', 2, 2),
('2026-09-18', '07:45:00', '09:00:00', 'Completed', 3, 3),
('2026-09-18', '08:15:00', '09:30:00', 'Completed', 4, 4),
('2026-09-19', '07:30:00', '08:45:00', 'Scheduled', 5, 5),
('2026-09-19', '08:00:00', '09:15:00', 'Scheduled', 6, 6),
('2026-09-19', '07:45:00', '09:00:00', 'Scheduled', 7, 7),
('2026-09-19', '08:15:00', '09:30:00', 'Scheduled', 8, 8),
('2026-09-20', '07:30:00', '08:45:00', 'Scheduled', 9, 9),
('2026-09-20', '08:00:00', '09:15:00', 'Scheduled', 10, 10);

-- BUS_TRACKING 
INSERT INTO bus_tracking (trip_id, latitude, longitude, recorded_at) VALUES
(1, 17.440081, 78.348915, '2026-09-18 07:45:00'),
(1, 17.450000, 78.360000, '2026-09-18 08:00:00'),
(2, 17.439900, 78.498300, '2026-09-18 08:20:00'),
(3, 17.423400, 78.371200, '2026-09-18 08:05:00'),
(4, 17.361600, 78.474700, '2026-09-18 08:30:00'),
(5, 17.240300, 78.429400, '2026-09-19 07:50:00'),
(6, 17.534000, 78.486000, '2026-09-19 08:10:00'),
(7, 17.490000, 78.320000, '2026-09-19 08:00:00'),
(8, 17.401000, 78.558000, '2026-09-19 08:35:00'),
(9, 17.345000, 78.552000, '2026-09-20 07:55:00');

-- CUSTOMERS 
INSERT INTO customers (name, email, phone, city, join_date) VALUES
('Ramesh Sharma', 'ramesh@example.com',  '9000000001', 'Hyderabad',    '2026-01-10'),
('Lakshmi Devi',  'lakshmi@example.com', '9000000002', 'Secunderabad', '2026-02-15'),
('Kiran Rao',     NULL,                  '9000000003', 'Miyapur',      '2026-03-20'),
('Anita Desai',   'anita@example.com',   '9000000004', 'Charminar',    '2026-03-25'),
('Suresh Menon',  'suresh@example.com',  '9000000005', 'Shamshabad',   '2026-04-01'),
('Divya Iyer',    'divya@example.com',   '9000000006', 'Kompally',     '2026-04-10'),
('Rahul Verma',   'rahul@example.com',   '9000000007', 'Lingampally',  '2026-04-18'),
('Meena Kumari',  'meena@example.com',   '9000000008', 'Uppal',        '2026-05-02'),
('Arvind Gupta',  NULL,                  '9000000009', 'LB Nagar',     '2026-05-12'),
('Shalini Reddy', 'shalini@example.com', '9000000010', 'Ameerpet',     '2026-05-20');

-- STUDENTS 
INSERT INTO students (student_name, department, phone) VALUES
('Arjun Mehta',   'CSE',  '9100000001'),
('Priya Nair',    'ECE',  '9100000002'),
('Vikram Singh',  'MECH', '9100000003'),
('Sneha Patel',   'IT',   '9100000004'),
('Rohit Sharma',  'CSE',  '9100000005'),
('Kavya Menon',   'EEE',  '9100000006'),
('Aditya Rao',    'CIVIL','9100000007'),
('Pooja Joshi',   'IT',   '9100000008'),
('Nikhil Reddy',  'ECE',  '9100000009'),
('Tanvi Shah',    'CSE',  '9100000010');

-- BUS_STOPS 
INSERT INTO bus_stops (route_id, stop_name, stop_order) VALUES
(1, 'Gachibowli Circle',    1),
(1, 'Hitech City',          2),
(1, 'College Main Gate',    3),
(2, 'Secunderabad Station', 1),
(2, 'Paradise Circle',      2),
(3, 'Miyapur X Road',       1),
(3, 'KPHB Colony',          2),
(4, 'Charminar',            1),
(5, 'Shamshabad Airport',   1),
(6, 'Kompally Cross',       1);

-- STUDENT_BUS 
INSERT INTO student_bus (student_id, bus_id, stop_id, assigned_date) VALUES
(1, 1, 1, '2026-06-01'),
(2, 1, 2, '2026-06-01'),
(3, 2, 4, '2026-06-02'),
(4, 3, 6, '2026-06-03'),
(5, 4, 8, '2026-06-04'),
(6, 5, 9, '2026-06-05'),
(7, 6, 10,'2026-06-06'),
(8, 7, 1, '2026-06-07'),
(9, 8, 2, '2026-06-08'),
(10,9, 4, '2026-06-09');

-- ORDERS 
INSERT INTO orders (customer_id, student_id, bus_id, order_date, total_amount, payment_mode) VALUES
(1, 1, 1, '2026-06-01', 2500.00, 'UPI'),
(2, 2, 1, '2026-06-01', 2500.00, 'Card'),
(3, 3, 2, '2026-06-02', 3000.00, 'Cash'),
(4, 4, 3, '2026-06-03', 2800.00, 'UPI'),
(5, 5, 4, '2026-06-04', 3200.00, 'Net Banking'),
(6, 6, 5, '2026-06-05', 2600.00, 'UPI'),
(7, 7, 6, '2026-06-06', 2900.00, 'Card'),
(8, 8, 7, '2026-06-07', 3100.00, 'Cash'),
(9, 9, 8, '2026-06-08', 2700.00, 'UPI'),
(10,10,9, '2026-06-09', 3000.00, 'Card');

-- ORDER_DETAILS 
INSERT INTO order_details (order_id, quantity_ordered, price_at_time_of_order) VALUES
(1, 1, 2500.00),
(2, 1, 2500.00),
(3, 1, 3000.00),
(4, 1, 2800.00),
(5, 1, 3200.00),
(6, 1, 2600.00),
(7, 1, 2900.00),
(8, 1, 3100.00),
(9, 1, 2700.00),
(10,1, 3000.00);

-- ATTENDANCE 
INSERT INTO attendance (student_id, trip_id, boarding_time, status, attendance_date) VALUES
(1, 1, '07:35:00', 'Present', '2026-09-18'),
(2, 1, '07:40:00', 'Present', '2026-09-18'),
(3, 2, '08:05:00', 'Present', '2026-09-18'),
(4, 2, '08:10:00', 'Absent',  '2026-09-18'),
(5, 3, '07:50:00', 'Present', '2026-09-18'),
(6, 4, '08:20:00', 'Present', '2026-09-18'),
(7, 5, '07:35:00', 'Present', '2026-09-19'),
(8, 6, '08:05:00', 'Present', '2026-09-19'),
(9, 7, '07:50:00', 'Absent',  '2026-09-19'),
(10,8, '08:20:00', 'Present', '2026-09-19');

-- COMPLAINTS 
INSERT INTO complaints (student_id, bus_id, complaint_text, complaint_date, status) VALUES
(2, 1, 'Bus arrived 15 minutes late.',     '2026-09-18', 'Open'),
(3, 2, 'AC not working properly.',         '2026-09-17', 'Resolved'),
(1, 1, 'Driver was rash driving.',         '2026-09-16', 'Open'),
(4, 3, 'Seat was broken.',                 '2026-09-15', 'Resolved'),
(5, 4, 'Bus skipped a stop.',              '2026-09-14', 'Open'),
(6, 5, 'Overcrowded during morning trip.', '2026-09-13', 'Open'),
(7, 6, 'Wi-Fi not available.',             '2026-09-12', 'Resolved'),
(8, 7, 'Late pick-up again.',              '2026-09-11', 'Open'),
(9, 8, 'Unclean interior.',                '2026-09-10', 'Resolved'),
(10,9, 'Driver did not stop at the gate.', '2026-09-09', 'Open');  

-- refund 
INSERT INTO bus_refunds
(student_id, refund_amount, dropout_date, refund_due_date, refund_status)
VALUES
(1, 3000.00, '2026-10-01', '2026-10-22', 'Pending'),
(2, 2500.00, '2026-10-05', '2026-10-26', 'Pending'),
(3, 1800.00, '2026-09-20', '2026-10-11', 'Approved'),
(4, 3200.00, '2026-10-10', '2026-10-31', 'Pending'),
(5, 2000.00, '2026-09-15', '2026-10-06', 'Approved'),
(6, 2800.00, '2026-10-12', '2026-11-02', 'Pending'),
(7, 2200.00, '2026-10-13', '2026-11-03', 'Pending'),
(8, 3500.00, '2026-09-10', '2026-10-01', 'Approved'),
(9, 1900.00, '2026-10-15', '2026-11-05', 'Pending'),
(10, 2700.00, '2026-09-25', '2026-10-16', 'Approved');  

-- bus_assignment_audit
INSERT INTO bus_assignment_audit
    (student_id, bus_id, action_type, action_date)
VALUES
    (1, 1, 'ASSIGNED', NOW()),
    (2, 2, 'ASSIGNED', NOW()),
    (3, 1, 'RELEASED', NOW()),
    (4, 3, 'ASSIGNED', NOW()),
    (5, 2, 'RELEASED', NOW()),
    (6, 1, 'ASSIGNED', NOW()),
    (7, 3, 'ASSIGNED', NOW()),
    (8, 2, 'RELEASED', NOW()),
    (9, 1, 'ASSIGNED', NOW()),
    (10, 3, 'RELEASED', NOW()); 
    
    -- refund_status_audit
    INSERT INTO refund_status_audit
    (refund_id, old_status, new_status, changed_at)
VALUES
    (1, 'Pending', 'Approved', NOW()),
    (2, 'Pending', 'Rejected', NOW()),
    (3, 'Pending', 'Approved', NOW()),
    (4, 'Approved', 'Completed', NOW()),
    (5, 'Pending', 'Approved', NOW()),
    (6, 'Approved', 'Completed', NOW()),
    (7, 'Pending', 'Rejected', NOW()),
    (8, 'Pending', 'Approved', NOW()),
    (9, 'Approved', 'Completed', NOW()),
    (10, 'Pending', 'Approved', NOW());
    
    INSERT INTO complaint_audit
    (complaint_id, student_id, action_type, action_date)
VALUES
    (1, 1, 'COMPLAINT_SUBMITTED', NOW()),
    (2, 2, 'COMPLAINT_SUBMITTED', NOW()),
    (3, 3, 'COMPLAINT_SUBMITTED', NOW()),
    (4, 4, 'COMPLAINT_SUBMITTED', NOW()),
    (5, 5, 'COMPLAINT_SUBMITTED', NOW()),
    (6, 6, 'COMPLAINT_SUBMITTED', NOW()),
    (7, 7, 'COMPLAINT_SUBMITTED', NOW()),
    (8, 8, 'COMPLAINT_SUBMITTED', NOW()),
    (9, 9, 'COMPLAINT_SUBMITTED', NOW()),
    (10, 10, 'COMPLAINT_SUBMITTED', NOW());

-- =====================================================================
-- PART 3: INDEXES
-- =====================================================================

CREATE INDEX idx_students_department ON students(department);
CREATE INDEX idx_studentbus_bus 	 ON student_bus(bus_id);
CREATE INDEX idx_trips_date 		 ON trips(trip_date);
CREATE INDEX idx_buses_route 		 ON buses(route_id);
CREATE INDEX idx_tracking_trip 		 ON bus_tracking(trip_id);
CREATE INDEX idx_complaints_status   ON complaints(status);
CREATE INDEX idx_attendance_date     ON attendance(attendance_date);
CREATE INDEX idx_routes_name         ON routes(route_name);

-- Verify indexes:
-- SHOW INDEX FROM students;
-- SHOW INDEX FROM student_bus;
-- SHOW INDEX FROM routes;
-- SHOW INDEX FROM attendance;

-- =====================================================================
-- PART 4: VIEWS
-- =====================================================================

-- 4.1 Student details for reporting/UI
CREATE OR REPLACE VIEW view_student_details AS
SELECT
    student_id,
    student_name,
    department,
    phone
FROM students;

SELECT * FROM view_student_details;

-- 4.2 Bus + route information for reporting/UI
CREATE OR REPLACE VIEW view_bus_routes AS
SELECT
    b.bus_id,
    b.bus_number,
    b.capacity,
    r.route_name
FROM buses b
JOIN routes r
    ON b.route_id = r.route_id;

SELECT * FROM view_bus_routes; 

-- 4.3 Student + bus + stop information for reporting/UI
CREATE OR REPLACE VIEW view_student_bus_assignments AS
SELECT
    s.student_id,
    s.student_name,
    b.bus_number,
    bs.stop_name
FROM student_bus sb
JOIN students s ON sb.student_id = s.student_id
JOIN buses b ON sb.bus_id = b.bus_id
JOIN bus_stops bs ON sb.stop_id = bs.stop_id;  

SELECT * FROM  view_student_bus_assignments;

-- 4.4 Students absent from bus trips
CREATE OR REPLACE VIEW view_absent_students AS
SELECT
    s.student_id,
    s.student_name,
    a.trip_id,
    a.attendance_date,
    a.status
FROM students s
JOIN attendance a
    ON s.student_id = a.student_id
WHERE a.status = 'Absent';

SELECT * FROM view_absent_students;

-- 4.5 Bus-wise student count
CREATE OR REPLACE VIEW view_bus_student_count AS
SELECT
    b.bus_id,
    b.bus_number,
    b.capacity,
    COALESCE(COUNT(sb.student_id), 0) AS total_students
FROM buses b
LEFT JOIN student_bus sb
    ON b.bus_id = sb.bus_id
GROUP BY b.bus_id, b.bus_number, b.capacity;

SELECT * FROM view_bus_student_count;

-- =====================================================================
-- PART 5: STORED PROCEDURES
-- =====================================================================
-- 5.1 All details of students
DROP PROCEDURE IF EXISTS sp_get_student_details;
DELIMITER //
CREATE PROCEDURE sp_get_student_details(IN p_student_id INT)
BEGIN
    SELECT student_id, student_name, department, phone
    FROM students
    WHERE student_id = p_student_id;
END //
DELIMITER ;

CALL sp_get_student_details(8);

-- if give the call in without a number 
DROP PROCEDURE IF EXISTS sp_get_all_students;
DELIMITER //

CREATE PROCEDURE sp_get_all_students()
BEGIN
    SELECT student_id, student_name, department, phone
    FROM students;
END //

DELIMITER ;

CALL sp_get_all_students();

-- 5.2 All students assigned to one bus
DROP PROCEDURE IF EXISTS sp_get_bus_students;
DELIMITER //
CREATE PROCEDURE sp_get_bus_students(IN p_bus_id INT)
BEGIN
    SELECT s.student_id, s.student_name, s.department, s.phone
    FROM students s
    JOIN student_bus sb ON s.student_id = sb.student_id
    WHERE sb.bus_id = p_bus_id
    ORDER BY s.student_name;
END //
DELIMITER ;

CALL sp_get_bus_students(1);

-- 5.3 Find drivers whose license number is above 10
DROP PROCEDURE IF EXISTS sp_get_drivers_license_above_10;
DELIMITER //
CREATE PROCEDURE sp_get_drivers_license_above_10()
BEGIN
    SELECT driver_id, driver_name, phone, license_no
    FROM drivers
    WHERE CAST(license_no AS UNSIGNED) > 10;
END //
DELIMITER ;

CALL sp_get_drivers_license_above_10();

-- 5.4 Find all students assigned to a particular stop and bus
DROP PROCEDURE IF EXISTS sp_get_bus_stop_students;
DELIMITER //
CREATE PROCEDURE sp_get_bus_stop_students(
    IN p_bus_id INT,
    IN p_stop_id INT
)
BEGIN
    SELECT s.student_id, s.student_name, s.department, s.phone
    FROM students s
    JOIN student_bus sb ON s.student_id = sb.student_id
    WHERE sb.bus_id = p_bus_id
      AND sb.stop_id = p_stop_id
    ORDER BY s.student_name;
END //
DELIMITER ;

CALL sp_get_bus_stop_students(1, 1);

-- 5.5 Student dropout, bus seat release, and refund management
DROP PROCEDURE IF EXISTS sp_student_dropout_refund;
DELIMITER //
CREATE PROCEDURE sp_student_dropout_refund(
    IN p_student_id INT,
    IN p_refund_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_assignment_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    SELECT COUNT(*)
    INTO v_assignment_count
    FROM student_bus
    WHERE student_id = p_student_id;
    IF v_assignment_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No bus assignment found for this student';
    END IF;
    INSERT INTO bus_refunds (
        student_id,
        refund_amount,
        dropout_date,
        refund_due_date,
        refund_status
    )
    VALUES (
        p_student_id,
        p_refund_amount,
        CURDATE(),
        DATE_ADD(CURDATE(), INTERVAL 21 DAY),
        'Pending'
    );
    DELETE FROM student_bus
    WHERE student_id = p_student_id;
    COMMIT;
END //
DELIMITER ;

CALL sp_student_dropout_refund(2, 2000.00);

-- =====================================================================
-- PART 6: TRIGGERS
-- =====================================================================
-- 6.1 Record a new bus assignment 
 -- Write a trigger to automatically record when a student is assigned to a bus.
 DROP TRIGGER IF EXISTS trg_bus_assignment_insert;

DELIMITER //
CREATE TRIGGER trg_bus_assignment_insert
AFTER INSERT ON student_bus
FOR EACH ROW
BEGIN
    INSERT INTO bus_assignment_audit
        (student_id, bus_id, action_type)
    VALUES
        (NEW.student_id, NEW.bus_id, 'ASSIGNED');
END //
DELIMITER ;

-- SHOW TRIGGERS;
-- SELECT * FROM bus_assignment_audit;

    -- 6.2  Record a deleted bus assignment
--  Write a trigger to record the release of a student's bus assignment.
DROP TRIGGER IF EXISTS trg_bus_assignment_delete;

DELIMITER //
CREATE TRIGGER trg_bus_assignment_delete
AFTER DELETE ON student_bus
FOR EACH ROW
BEGIN
    INSERT INTO bus_assignment_audit
        (student_id, bus_id, action_type)
    VALUES
        (OLD.student_id, OLD.bus_id, 'RELEASED');
END //
DELIMITER ;
-- SHOW TRIGGERS;
-- SELECT * FROM refund_status_audit;

-- 6.3Trigger to validate bus capacity
-- Write a trigger to prevent inserting a bus with zero or negative capacity.
DROP TRIGGER IF EXISTS trg_check_bus_capacity;

DELIMITER //
CREATE TRIGGER trg_check_bus_capacity
BEFORE INSERT ON buses
FOR EACH ROW
BEGIN
    IF NEW.capacity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bus capacity must be greater than zero';
    END IF;
END //
DELIMITER ;

-- 6.4 trigger to record new complaints
--  Write a trigger to record a new student complaint automatically.

DROP TRIGGER IF EXISTS trg_complaint_insert;

DELIMITER //
CREATE TRIGGER trg_complaint_insert
AFTER INSERT ON complaints
FOR EACH ROW
BEGIN
    INSERT INTO complaint_audit
        (complaint_id, student_id, action_type)
    VALUES
        (NEW.complaint_id, NEW.student_id, 'COMPLAINT_SUBMITTED');
END //

DELIMITER ;
-- SHOW TRIGGERS;
-- SELECT * FROM complaint_audit;


-- Basic SQL Queries
--  Display student names and departments
SELECT student_name, department FROM students;

-- Display all student details
SELECT * FROM students;

-- Display students from the CSE department
SELECT * FROM students WHERE department = 'CSE';

--  Display buses with capacity greater than 40
SELECT * FROM buses WHERE capacity > 40;

-- Display buses with capacity between 30 and 60
SELECT * FROM buses WHERE capacity BETWEEN 30 AND 60;

-- Display all drivers
SELECT driver_name, phone, license_no FROM drivers;

-- Display bus stops for a particular route
SELECT stop_name, stop_order FROM bus_stops
WHERE route_id = 1
ORDER BY stop_order;

-- Display student names and assigned bus numbers
SELECT s.student_name, b.bus_number FROM students s
JOIN student_bus sb ON s.student_id = sb.student_id
JOIN buses b ON sb.bus_id = b.bus_id;

-- Count the total number of students
SELECT COUNT(*) AS total_students FROM students;

-- Count the number of buses
SELECT COUNT(*) AS total_buses FROM buses;

-- Display complaints that are still pending
SELECT * FROM complaints WHERE status = 'Pending';

-- Display trips in descending date order
SELECT * FROM trips
ORDER BY trip_date DESC;

SELECT * FROM trips ORDER BY trip_date ;

-- Display the total number of students assigned to each bus
SELECT b.bus_number, COUNT(sb.student_id) AS total_students
FROM buses b
LEFT JOIN student_bus sb ON b.bus_id = sb.bus_id
GROUP BY b.bus_id, b.bus_number;

-- Display routes with a distance greater than 10
SELECT route_name, start_location, end_location, distance
FROM routes
WHERE distance > 10;

-- Display complaints with student names
SELECT s.student_name, c.complaint_text, c.status
FROM students s
JOIN complaints c ON s.student_id = c.student_id;

-- SELECT * FROM drivers;
-- SELECT * FROM routes;
-- SELECT * FROM buses;
-- SELECT * FROM trips;
-- SELECT * FROM bus_tracking;
-- SELECT * FROM customers;
-- SELECT * FROM students;
-- SELECT * FROM bus_stops;
-- SELECT * FROM student_bus;
-- SELECT * FROM orders;
-- SELECT * FROM order_details;
-- SELECT * FROM attendance;
-- SELECT * FROM complaints;
-- SELECT * FROM bus_refunds;
-- SELECT * FROM bus_assignment_audit;
-- SELECT * FROM refund_status_audit;
-- SELECT * FROM complaint_audit;
