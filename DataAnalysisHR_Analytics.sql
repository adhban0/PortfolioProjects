----------------------------------------- Data Analysis ---------------------------------------------------------------

-- Attrition Rate Per Department: R&D department has the highest attrition rate of 9.05%, followed by Sales (6.26%) and finally HR (0.82%)
with AttritionCte as
(
select COUNT(attrition) as total_attrition
from [HR-Employee-Attrition]
)
select department,Round((cast(count(attrition) as float)/total_attrition)*100,2) as Attrition_Percent
from AttritionCte,[HR-Employee-Attrition]
where attrition = 'YES'
group by Department,total_attrition

-- Attrition Rate According to Business Travel:  Employees who travel frequently are content with their jobs but find it troublesome, while those who travel rarely find themselves less engaged. Employees who never travel have the least attrition rate because of the stability of their jobs. 
with attrition_cte as
(
select COUNT(attrition) as total_attrition
from [HR-Employee-Attrition]
)
select BusinessTravel,Round((cast(count(attrition) as float)/total_attrition)*100,2) as Attrition_Percent
from attrition_cte,[HR-Employee-Attrition]
where attrition = 'YES'
group by BusinessTravel,total_attrition

-- Average and Median Age (Seniority/Experience) for each Job Level: The average age (experience) increases as you move up job levels
select JobLevel, round(avg(Age),2) as Average_Age
from [HR-Employee-Attrition]
group by JobLevel
order by Average_Age

SELECT Distinct JobLevel,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) 
OVER (PARTITION BY Joblevel) AS Median_Age
FROM [HR-Employee-Attrition]
order by Median_Age

-- Correlation Between Job Level and Education Level: The higher the education level the higher the job level
select Education as EducationLevel, Round(avg(JobLevel),2) as Average_Job_Level
from [HR-Employee-Attrition]
group by Education
order by Education

-- Gender Diversity in Departments: Males are notably more than females
select Department, Gender,
round(cast(count(*)*100.0/sum(count(*)) over (partition by department) as decimal(5,2)),2) as [Percentage]
from [HR-Employee-Attrition]
group by Department, Gender
order by Department,[Percentage] DESC

-- Education fields Distribuition by Department: Life sciences (49.05%), Human resources (45%) and Marketing (36%) are the most popular education fields for R&D, HR and Sales departments, respectively.
with education_field_cte as(
select Department, EducationField,
round(cast(count(*)*100.0/sum(count(*)) over (partition by department) as decimal(5,2)),2) as [Percentage]
from [HR-Employee-Attrition]
where EducationField != 'OTHER'
group by Department, EducationField
), education_field_cte2 as(
select department,educationfield,[percentage], ROW_NUMBER()over(partition by department order by [percentage] desc) as ranking
from education_field_cte
)
select Department, EducationField, [Percentage]
from education_field_cte2
where ranking = 1

-- Impact of Training on Performance: Training has had no impact on employee performance.
select TrainingTimesBracket, round(Avg(PerformanceRating),2) as AveragePerformanceRating
from [HR-Employee-Attrition]
group by TrainingTimesBracket

-- Environment Satisfaction By Department: R&D department has the highest average environment satisfaction rating (2.74 out of 5), followed by Sales and HR (2.68 out of 5). However, all of these are mediocre ratings and all departments should work to solve this issue.
select Department, Round(avg(EnvironmentSatisfaction),2) as AverageEnvironmentSatisfaction
from [HR-Employee-Attrition]
group by Department

-- Impact of Being a Stockholder on Job Commitment: Stockholders are more willing to work overtime and also show more job involvement than non-stockholders 
select
case
	when StockOptionLevel = 0 then 'NON-STOCKHOLDER'
	else 'STOCKHOLDER'
end as TypeOfEmployee
, count(overtime) as DoesOvertime,round(avg(JobInvolvement),2) as AverageJobInvolvement
from [HR-Employee-Attrition]
group by case
	when StockOptionLevel = 0 then 'NON-STOCKHOLDER'
	else 'STOCKHOLDER'
	end