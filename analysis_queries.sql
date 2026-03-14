SELECT COUNT(*) FROM map_features;
SELECT COUNT(*) FROM mapping_tasks;
SELECT COUNT(*) FROM quality_checks;
#-------------------------
### Checked Data Quality
#---------------------------
SELECT *
FROM mapping_tasks
WHERE end_date IS NULL;

SELECT task_status, COUNT(*)
FROM mapping_tasks
GROUP BY task_status;
#-----------------------------
### business questions
#-------------------------------

#1.City-wise feature count

SELECT city, COUNT(*) AS total_features
FROM map_features
GROUP BY city
ORDER BY total_features DESC;

#2.Feature type distribution

SELECT feature_type, COUNT(*) AS total
FROM map_features
GROUP BY feature_type
ORDER BY total DESC;

#3.Mapper productivity

SELECT mapped_by, COUNT(*) AS completed_tasks
FROM mapping_tasks
WHERE task_status='Completed'
GROUP BY mapped_by
ORDER BY completed_tasks DESC;

#4.Count of failed QC

SELECT count(qc_status) as Rej_QC
FROM quality_checks
WHERE qc_status = 'Rejected';

#5.Average task completion time 

SELECT AVG(DATEDIFF(end_date,start_date)) AS avg_days
FROM mapping_tasks
WHERE task_status='Completed';

#6.QC Pass Rate 

SELECT 
qc_status,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM quality_checks
GROUP BY qc_status;

#7.Ranking  mappers based on productivity 

SELECT 
mapped_by,
COUNT(*) AS tasks_completed,
RANK() OVER(ORDER BY COUNT(*) DESC) AS productivity_rank
FROM mapping_tasks
WHERE task_status='Completed'
GROUP BY mapped_by;

#8.Classify task performance 

SELECT 
task_id,
mapped_by,
DATEDIFF(end_date,start_date) AS completion_days,
CASE 
WHEN DATEDIFF(end_date,start_date) <=1 THEN 'Fast'
WHEN DATEDIFF(end_date,start_date) <=3 THEN 'Normal'
ELSE 'Slow'
END AS performance_category
FROM mapping_tasks
WHERE task_status='Completed';

#9.Find mappers who completed above average tasks 

SELECT mapped_by, COUNT(*) AS tasks_completed
FROM mapping_tasks
WHERE task_status='Completed'
GROUP BY mapped_by
HAVING COUNT(*) >
(
SELECT AVG(task_count)
FROM
(
SELECT COUNT(*) AS task_count
FROM mapping_tasks
WHERE task_status='Completed'
GROUP BY mapped_by
) avg_tasks
);

#10.Latest QC Record 

SELECT *
FROM
(
SELECT 
qc_id,
task_id,
qc_status,
ROW_NUMBER() OVER(PARTITION BY task_id ORDER BY qc_date DESC) AS rn
FROM quality_checks
) q
WHERE rn = 1;

#11.View Creation 

CREATE VIEW mapping_analysis AS
SELECT 
m.feature_type,
t.mapped_by,
q.qc_status
FROM map_features m
JOIN mapping_tasks t
ON m.feature_id = t.feature_id
JOIN quality_checks q
ON t.task_id = q.task_id;

#16.Top 3 Mappers details

SELECT *
FROM
(
SELECT 
mapped_by,
COUNT(*) AS tasks_completed,
RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
FROM mapping_tasks
WHERE task_status='Completed'
GROUP BY mapped_by
) t
WHERE rnk<=3;
SELECT *
FROM mapping_analysis;

#12.Tasks Completed Per Day 

SELECT end_date, COUNT(*) AS tasks_completed
FROM mapping_tasks
WHERE task_status='Completed'
GROUP BY end_date
ORDER BY end_date;

#13.Tasks Taking More Than 2 Days 

SELECT task_id
FROM mapping_tasks
WHERE DATEDIFF(end_date,start_date) > 2;

#14.Feature Types With Most Tasks 

SELECT 
m.feature_type,
COUNT(*) AS total_tasks
FROM map_features m
JOIN mapping_tasks t
ON m.feature_id=t.feature_id
GROUP BY m.feature_type
ORDER BY total_tasks DESC;

#15.QC Engineers Workload

SELECT qc_engineer, COUNT(*) AS tasks_reviewed
FROM quality_checks
GROUP BY qc_engineer
ORDER BY tasks_reviewed DESC;

#16.QC Approval Trend 

SELECT 
qc_date,
COUNT(*) AS approvals
FROM quality_checks
WHERE qc_status='Approved'
GROUP BY qc_date
ORDER BY qc_date;

