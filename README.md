# 🚌 College Bus Tracking System

## 📖 Project Overview

The College Bus Tracking System is a relational database project developed using MySQL. It is designed to organize and manage college transportation information, including buses, drivers, students, bus stops, schedules, and student bus assignments.

The project demonstrates the practical implementation of:

- ER diagram design
- Database and table creation
- Primary keys and foreign keys
- Data insertion and modification
- Relationships between tables
- Constraints for data integrity
- SQL queries of different difficulty levels
- Indexes and views
- Stored procedures and triggers, where implemented

## ✨ Features

- Relational database design for college transportation management
- Primary keys and foreign keys to establish relationships
- Constraints to maintain data accuracy
- Bus, driver, student, stop, and schedule records
- Student-to-bus assignment management
- SQL queries for retrieving transportation information
- Aggregate functions and joins for data analysis
- Indexes for improving query performance
- Views for displaying selected information
- Stored procedures and triggers, where included in the SQL script
- ER diagram and project presentation included

## 🛠️ Technologies Used

- **Database:** MySQL
- **Query Language:** SQL
- **Database Tool:** MySQL Workbench / MySQL Command Line Client
- **Version Control:** Git
- **Repository Hosting:** GitHub

## 🗺️ ER Diagram

The project uses an Entity Relationship (ER) Diagram to represent the database entities, attributes, primary keys, foreign keys, and relationships.

The diagram provides a visual representation of how transportation information is organized and how the tables are connected.

**ER Diagram:** `ER DAIGGRAM CBT.png`

The ER diagram is included in this repository.

## 🗄️ Database Tables

The project includes tables for managing the main components of college transportation.

The following are the core entities represented in the project:

- **Buses** — stores bus identification, registration, capacity, and status details.
- **Drivers** — stores driver information and availability details.
- **Students** — stores student records.
- **Bus Stops** — stores transportation stop information.
- **Bus Schedules** — stores bus scheduling information.
- **Student Bus Assignments** — connects students with their assigned buses and stops.

The exact table names, attributes, and total table count should be verified from the SQL script.

## 🔗 Relationships

The database uses primary and foreign keys to establish relationships between transportation records.

- A bus can be associated with multiple student assignments.
- A student can be connected to a bus through an assignment record.
- A bus stop can be referenced by multiple student assignments.
- Bus schedules store information about planned transportation services.
- Driver and bus relationships depend on the foreign keys defined in the schema.

These relationships help maintain organized records and reduce unnecessary data duplication.

## ⚙️ Database Objects

### ⚡ Indexes

Indexes can improve the speed of queries that frequently search or filter transportation records.

The project includes index definitions where specified in the SQL script.

Topics:
- CREATE INDEX
- UNIQUE INDEX, where implemented
- Indexing selected columns
- Query performance considerations

### 👁️ Views

Views provide reusable ways to display selected information from database tables.

They can simplify queries involving joins and help prepare transportation reports.

Possible applications include:

- Student bus assignment details
- Bus and driver information
- Bus schedule reports
- Student counts by bus

The actual view names and definitions are available in the SQL script.

### 🔔 Triggers

Triggers automatically execute database operations when specified events occur.

Where implemented, triggers can support:

- BEFORE INSERT and AFTER INSERT operations
- BEFORE UPDATE and AFTER UPDATE operations
- BEFORE DELETE and AFTER DELETE operations
- Data validation
- Audit logging
- Maintaining related records

Refer to the SQL script for the exact triggers and business rules implemented in this project.

### 📦 Stored Procedures

Stored procedures store reusable SQL operations in the database.

Where included, they can help simplify repeated database tasks, such as retrieving records, processing assignments, or generating reports.

Topics:
- CREATE PROCEDURE
- CALL
- IN, OUT, and INOUT parameters
- DELIMITER
- Reusable database operations

## 📝 SQL Topics Included

### 🟢 Basic Level

- CREATE DATABASE
- CREATE TABLE
- INSERT
- SELECT
- UPDATE
- DELETE
- WHERE
- DISTINCT
- ORDER BY
- LIMIT
- LIKE
- BETWEEN
- IN
- IS NULL and IS NOT NULL

### 🟡 Intermediate Level

- Primary keys and foreign keys
- UNIQUE, NOT NULL, CHECK, and DEFAULT constraints
- Aggregate functions
- COUNT()
- SUM()
- MIN() and MAX()
- AVG()
- GROUP BY
- HAVING
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- String functions
- Date functions
- COALESCE()

### 🔴 Advanced Level

- Multi-table joins
- Subqueries
- Nested queries
- CASE expressions
- Indexes
- Views
- Stored procedures
- Triggers
- Transaction control
- Data integrity and referential integrity

The exact set of implemented topics depends on the SQL statements included in the project file.

## ▶️ How to Run

1. Install MySQL Server and open MySQL Workbench.
2. Open `college bus tracking project.sql`.
3. Review the script and check the database name.
4. Execute the SQL statements in the correct order.
5. Verify the database and tables using `SHOW TABLES`.
6. Inspect table structures using `DESCRIBE table_name`.
7. Check the inserted sample records using SELECT queries.
8. Execute the joins, aggregate functions, and other queries.
9. Test the indexes, views, procedures, and triggers that are included.
10. Compare the database structure with the ER diagram.

**Note:** Back up existing data before running any script that drops or recreates database objects.

## 📂 Project Files

- `college bus tracking project.sql` — SQL script containing the database implementation.
- `ER DAIGGRAM CBT.png` — ER diagram illustrating the database design.
- `college bus tracking ppt.pptx` — PowerPoint presentation explaining the project.
- `README.md` — Project documentation.

## 🎓 Learning Outcomes

This project provides practical experience in:

- Relational database design
- ER diagram preparation
- Database normalization
- Primary keys and foreign keys
- SQL query writing
- Joins and aggregate functions
- Data filtering and grouping
- Constraints and data integrity
- Indexes and views
- Stored procedures and triggers
- Git and GitHub version control

## 🔮 Future Scope

- **Real-Time GPS Tracking:** Integrate GPS devices to track buses on a live map.
- **Web Application:** Develop a frontend and backend for students and administrators.
- **Mobile Application:** Provide transportation information through a mobile app.
- **Notifications:** Send bus arrival and schedule notifications.
- **Attendance Management:** Record student boarding and bus attendance.
- **Reporting and Analytics:** Create dashboards for bus utilization and transportation planning.
- **Cloud Deployment:** Deploy the application and database to a suitable cloud platform.

These are potential enhancements, not claims that these features are already implemented.

## 👩‍💻 Author

Kamakshi Kosuru

## 🔗 GitHub Repository

[College Bus Tracking System](https://github.com/kamakshikosuru03-hub/college_bus_tracking)

## ✅ Conclusion

The College Bus Tracking System demonstrates how MySQL can be used to organize and manage college transportation data through a relational database.

The project applies database design principles, SQL queries, table relationships, and database objects to support transportation record management. It also provides a foundation for future enhancements such as real-time GPS tracking and web-based transportation management.

