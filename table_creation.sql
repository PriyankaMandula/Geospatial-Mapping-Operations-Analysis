CREATE DATABASE mapping_project;
DROP DATABASE mapping_project;
USE mapping_project;
#-------creating tables in side data base--------------
CREATE TABLE map_features(
feature_id INT PRIMARY KEY,
feature_type VARCHAR(50),
city VARCHAR(50),
latitude FLOAT,
longitude FLOAT,
created_date DATE
);
SELECT*FROM map_Features;

####################
CREATE TABLE mapping_tasks(
task_id INT PRIMARY KEY,
feature_id INT,
mapped_by VARCHAR(50),
task_status VARCHAR(50),
start_date DATE,
end_date DATE
);

SELECT*FROM mapping_tasks;

CREATE TABLE quality_checks(
qc_id INT PRIMARY KEY,
task_id INT,
qc_engineer VARCHAR(50),
qc_status VARCHAR(50),
qc_date DATE
);

select * from quality_checks;










