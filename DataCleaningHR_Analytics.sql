----------------------------------------- Data Cleaning ---------------------------------------------------------------

-- Delete useless columns
ALTER TABLE [HR-Employee-Attrition]
drop column employeecount;

ALTER TABLE [HR-Employee-Attrition]
drop column [over18];

ALTER TABLE [HR-Employee-Attrition]
drop column [StandardHours];
-- Standardize Data Types
ALTER TABLE [HR-Employee-Attrition]
ADD CONSTRAINT attrition_ck 
CHECK (attrition IN ('Yes', 'No'));

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN attrition nVARCHAR(3);

ALTER TABLE [HR-Employee-Attrition]
ADD CONSTRAINT BusinessTravel_ck 
CHECK (BusinessTravel IN ('Non-Travel', 'Travel_Rarely','Travel_Frequently'));

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN BusinessTravel nVARCHAR(18);

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN EducationField nVARCHAR(40);

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN EmployeeNumber float not null;

ALTER TABLE [HR-Employee-Attrition]
ADD CONSTRAINT employeenumber_pk 
PRIMARY KEY (EmployeeNumber);

ALTER TABLE [HR-Employee-Attrition]
ADD CONSTRAINT Gender_ck 
CHECK (Gender IN ('Male', 'Female'));

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN Gender nVARCHAR(6);

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN JobRole nVARCHAR(40);

ALTER TABLE [HR-Employee-Attrition]
ADD CONSTRAINT MaritalStatus_ck 
CHECK (MaritalStatus IN ('Single', 'Divorced','Married'));

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN MaritalStatus nVARCHAR(8);

ALTER TABLE [HR-Employee-Attrition]
ADD CONSTRAINT overtime_ck 
CHECK (overtime IN ('Yes', 'No'));

ALTER TABLE [HR-Employee-Attrition]
ALTER COLUMN overtime nVARCHAR(3);

-- Adding new columns
alter table [HR-Employee-Attrition]
add TrainingTimesBracket as 
case
	when trainingtimeslastyear>=3 then '3 OR MORE'
	when trainingtimeslastyear<3 then 'LESS THAN 3'
	else 'UNKNOWN'
end

-- Converting all text to Uppercase and trim spaces

update [HR-Employee-Attrition]
set Attrition = Trim(UPPER(attrition))

update [HR-Employee-Attrition]
set BusinessTravel = Trim(UPPER(BusinessTravel))

update [HR-Employee-Attrition]
set Department = Trim(UPPER(Department))

update [HR-Employee-Attrition]
set EducationField = Trim(UPPER(EducationField))

update [HR-Employee-Attrition]
set Gender = Trim(UPPER(Gender))

update [HR-Employee-Attrition]
set JobRole = Trim(UPPER(JobRole))

update [HR-Employee-Attrition]
set MaritalStatus= Trim(UPPER(MaritalStatus))

update [HR-Employee-Attrition]
set OverTime = Trim(UPPER(OverTime))

-- Removing duplicates (no duplicates found)
with DuplicatesCTE as
(
select ROW_NUMBER() over(partition by employeenumber,jobrole,joblevel,monthlyincome,numcompaniesworked order by employeenumber) as row_num
from [HR-Employee-Attrition])
delete
from DuplicatesCTE
where row_num>1

-- No Outliers Found
-- Reordered the columns
-- No Null Values (Checked Kaggle Analysis)
