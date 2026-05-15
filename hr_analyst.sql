create database hr_analyst;
use hr_analyst;

CREATE TABLE hr_raw (
    EmpID                    VARCHAR(10),
    Age                      INT,
    AgeGroup                 VARCHAR(10),
    Attrition                VARCHAR(5),
    BusinessTravel           VARCHAR(30),
    DailyRate                INT,
    Department               VARCHAR(50),
    DistanceFromHome         INT,
    Education                INT,
    EducationField           VARCHAR(30),
    EmployeeCount            INT,
    EmployeeNumber           INT,
    EnvironmentSatisfaction  INT,
    Gender                   VARCHAR(10),
    HourlyRate               INT,
    JobInvolvement           INT,
    JobLevel                 INT,
    JobRole                  VARCHAR(50),
    JobSatisfaction          INT,
    MaritalStatus            VARCHAR(15),
    MonthlyIncome            INT,
    SalarySlab               VARCHAR(15),
    MonthlyRate              INT,
    NumCompaniesWorked       INT,
    Over18                   VARCHAR(2),
    OverTime                 VARCHAR(5),
    PercentSalaryHike        INT,
    PerformanceRating        INT,
    RelationshipSatisfaction INT,
    StandardHours            INT,
    StockOptionLevel         INT,
    TotalWorkingYears        INT,
    TrainingTimesLastYear    INT,
    WorkLifeBalance          INT,
    YearsAtCompany           INT,
    YearsInCurrentRole       INT,
    YearsSinceLastPromotion  INT,
    YearsWithCurrManager     INT
);
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Home/Downloads/hr_Analytics.csv'
INTO TABLE hr_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE hr_raw
SET BusinessTravel = 'Travel_Rarely'
WHERE BusinessTravel = 'TravelRarely';

SELECT BusinessTravel, COUNT(*) AS employee_count
FROM hr_raw
GROUP BY BusinessTravel
ORDER BY employee_count DESC;

UPDATE hr_raw
SET YearsWithCurrManager = 7
WHERE YearsWithCurrManager IS NULL;

alter table hr_raw add column attrition_flag varchar(30);
update hr_raw set attrition_flag =( case when attrition="Yes" then 1 else 0 end);

SELECT
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN MonthlyIncome IS NULL THEN 1 ELSE 0 END) AS missing_income,
    SUM(CASE WHEN JobRole IS NULL THEN 1 ELSE 0 END) AS missing_jobrole,
    SUM(CASE WHEN YearsWithCurrManager IS NULL THEN 1 ELSE 0 END) AS missing_manager_years
FROM hr_raw;

SELECT EmpID, COUNT(*) AS duplicate_count
FROM hr_raw
GROUP BY EmpID
HAVING COUNT(*) > 1;

SELECT EmpID, Age, TotalWorkingYears
FROM hr_raw
WHERE TotalWorkingYears > (Age - 18);

SELECT EmpID, TotalWorkingYears, YearsAtCompany
FROM hr_raw
WHERE YearsAtCompany > TotalWorkingYears;


SELECT
    COUNT(*) AS total_employees,
    SUM(AttritionFlag) AS attrition_count,
    COUNT(*) - SUM(AttritionFlag) AS active_employees,
    ROUND(100 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate
FROM hr_raw;


SELECT
    MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    ROUND(AVG(Age),2) AS avg_age
FROM hr_raw;


SELECT
    MIN(MonthlyIncome) AS min_income,
    MAX(MonthlyIncome) AS max_income,
    ROUND(AVG(MonthlyIncome),2) AS avg_income
FROM hr_raw;


SELECT
    Attrition,
    COUNT(*) AS employee_count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hr),2) AS percentage
FROM hr_raw
GROUP BY Attrition;

SELECT
    Department,
    COUNT(*) AS employee_count
FROM hr_raw
GROUP BY Department
ORDER BY employee_count DESC;


SELECT
    Gender,
    COUNT(*) AS employee_count
FROM hr_raw
GROUP BY Gender;


SELECT
    OverTime,
    COUNT(*) AS employee_count
FROM hr_raw
GROUP BY OverTime;

SELECT
    JobRole,
    COUNT(*) AS employee_count
FROM hr_raw
GROUP BY JobRole
ORDER BY employee_count DESC;

SELECT
    CONCAT(FLOOR(age/5)*5, '-', FLOOR(age/5)*5+4) AS bucket,
    COUNT(*) AS cnt
FROM hr_raw
GROUP BY bucket
ORDER BY bucket;

select dailyrate,ntile(4) over(order by dailyrate desc)as quartile from hr_raw;

select case when distancefromhome <= 5 then '01-05 km'
when distancefromhome<=10 then '06-10 km'
when distancefromhome<=15 then '11-15 km'
when distancefromhome<=20 then '16-20 km'
else '21-29 km'
end as distance_bucket,count(*) as cnt from hr_raw group by 1 order by 1 ;

select environmentsatisfaction ,case when environmentsatisfaction=1 then "Low" 
when environmentsatisfaction=2 then "medium" when environmentsatisfaction=3 then "high" 
when environmentsatisfaction=4 then "very high"
end as label,count(*) as employees from hr_raw group by environmentsatisfaction
order by environmentsatisfaction;

select 	hourlyrate ,ntile(4) over(order by hourlyrate desc) as quartile from hr_raw
group by hourlyrate ;

select jobinvolvement ,case jobinvolvement when 1 then "Low"
when 2 then "medium" when 3 then "high" when 4 then "very high"
end as label ,count(*) as cnt  from hr_raw group by jobinvolvement order by jobinvolvement;

select joblevel , count(*) as cnt from hr_raw group by joblevel order by joblevel;

select jobsatisfaction ,case jobsatisfaction when 1 then "Low"
when 2 then "medium" when 3 then "high" when 4 then "very high"
end as label ,count(*) as cnt  from hr_raw group by jobsatisfaction order by jobsatisfaction;

select monthlyincome ,ntile(4) over(order by monthlyincome desc) as quartiel from hr_raw
group by monthlyincome order by monthlyincome;

select monthlyrate ,ntile(4) over(order by monthlyrate desc) as quartile from hr_raw
group by monthlyrate order by monthlyrate;

select numcompaniesworked ,count(*)  from hr_raw group by numcompaniesworked order by numcompaniesworked;

select percentsalaryhike ,count(*)  from hr_raw group by percentsalaryhike order by percentsalaryhike;

select performancerating,case performancerating when 1 then "Low"
when 2 then "Good" when 3 then "Excellent" when 4 then "Outstanding"
end as label,count(*) as employees from hr_raw group by performancerating;

select relationshipsatisfaction,case relationshipsatisfaction when 1 then "Low"
when 2 then "Medium" when 3 then "High" when 4 then "very High"
end as label,count(*) as employees from hr_raw group by relationshipsatisfaction;

select trainingtimeslastyear,count(*) as cnt from hr_raw
group by trainingtimeslastyear order by trainingtimeslastyear;

select worklifebalance,case worklifebalance when 1 then "Bad"
when 2 then "Good" when 3 then "Better" when 4 then "Best"
end as label,count(*) as employees from hr_raw group by worklifebalance;

select case when yearsatcompany= 0 then "0 yrs"
when yearsatcompany<= 2 then "1-2 yrs"
when yearsatcompany<= 5 then "3-5 yrs"
when yearsatcompany<= 10 then "6-10 yrs"
else "10+ yrs" end as label ,count(*) as cnt from hr_raw group by 1 order by 1;

select yearsincurrentrole,count(*) as cnt from hr_raw group by yearsincurrentrole;
select yearssincelastpromotion,count(*) as cnt from hr_raw group by yearssincelastpromotion;
select yearswithcurrmanager,count(*) as cnt from hr_raw group by yearswithcurrmanager;

select attrition_flag from hr_raw;

select agegroup ,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by agegroup order by agegroup;


select businesstravel ,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by businesstravel order by businesstravel;

select department ,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by department order by department;

select education ,case education when 1 then "1-below college" 
when 2 then "2-college" when 3 then "3-bachelor"
when 4 then "4-master" when 5 then "5-phd"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by education order by education;

select educationfield ,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by educationfield order by educationfield;

select environmentsatisfaction ,case environmentsatisfaction when 1 then "low" 
when 2 then "medium" when 3 then "high"
when 4 then "very high"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by environmentsatisfaction order by environmentsatisfaction;

select gender,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by gender order by gender;

select jobinvolvement,case jobinvolvement when 1 then "low" 
when 2 then "medium" when 3 then "high"
when 4 then "very high"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by jobinvolvement order by jobinvolvement;

select joblevel,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by joblevel order by joblevel;

select jobrole,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by jobrole order by jobrole;

select jobsatisfaction,case jobsatisfaction when 1 then "low" 
when 2 then "medium" when 3 then "high"
when 4 then "very high"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by jobsatisfaction order by jobsatisfaction;

select maritalstatus,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by maritalstatus order by maritalstatus;

select overtime,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by overtime order by overtime;

select performancerating,case performancerating when 1 then "low" 
when 2 then "good" when 3 then "excellent"
when 4 then "outstanding"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by performancerating order by performancerating;

select relationshipsatisfaction,case relationshipsatisfaction when 1 then "low" 
when 2 then "medium" when 3 then "high"
when 4 then "very high"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by relationshipsatisfaction order by relationshipsatisfaction;

select salaryslab,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by salaryslab order by salaryslab;

select stockoptionlevel,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by stockoptionlevel order by stockoptionlevel;

select worklifebalance,case worklifebalance when 1 then "Bad" 
when 2 then "Good" when 3 then "better"
when 4 then "Best"
end as label ,
count(*) as cnt , sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by worklifebalance order by worklifebalance;

select case when numcompaniesworked=0 then "0-first job"
when numcompaniesworked<=2 then "1-2 Companies"
when numcompaniesworked<=5 then "3-5 Companies"
else "6-9 Companies"
end as hooping_bucket,
count(*) as total ,sum(attrition_flag) as arttrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by 1 order by attrition_rate desc;


select case when distancefromhome<=5 then "01-05 km"
when distancefromhome<=10 then "06-10 km"
when distancefromhome<=15 then "11 -15 km"
when distancefromhome<=20 then "16-20 km"
else "21-29"
end as distance_bucket,
count(*) as total ,sum(attrition_flag) as arttrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by 1 order by attrition_rate desc;


select trainingtimeslastyear,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by trainingtimeslastyear order by trainingtimeslastyear;

select YearsSinceLastPromotion,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by YearsSinceLastPromotion order by YearsSinceLastPromotion;

select YearsWithCurrManager,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by YearsWithCurrManager order by YearsWithCurrManager;

select YearsInCurrentRole,count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate 
from hr_raw group by YearsInCurrentRole order by YearsInCurrentRole;


select attrition , count(*) as cnt,
round(avg(age),2) as avg_age ,
round(avg(DailyRate),2) as DailyRate ,
round(avg(DistanceFromHome),2) as avg_DistanceFromHome,
round(avg(EnvironmentSatisfaction),2) as avg_EnvironmentSatisfaction ,
round(avg(HourlyRate),2) as avg_HourlyRate ,
round(avg(JobInvolvement),2) as avg_JobInvolvement ,
round(avg(JobLevel),2) as avg_JobLevel ,
round(avg(JobSatisfaction),2) as avg_JobSatisfaction ,
round(avg(MonthlyIncome),2) as avg_MonthlyIncome ,
round(avg(MonthlyRate),2) as avg_MonthlyRate ,
round(avg(NumCompaniesWorked),2) as avg_NumCompaniesWorked ,
round(avg(PercentSalaryHike),2) as avg_PercentSalaryHike ,
round(avg(PerformanceRating),2) as avg_PerformanceRating ,
round(avg(RelationshipSatisfaction),2) as avg_RelationshipSatisfaction ,
round(avg(StockOptionLevel),2) as avg_StockOptionLevel ,
round(avg(TotalWorkingYears),2) as avg_TotalWorkingYears 
from hr_raw group by attrition;

select department,gender,
count(*) as cnt ,sum(attrition_flag) as attrited,
round(100*sum(attrition_flag) /count(*),2) as attrition_rate
from hr_raw group by department ,gender order by department ,attrition_rate desc;

select jobrole,overtime,
count(*) as cnt ,sum(attrition_flag) as attrited,
round(100*sum(attrition_flag) /count(*),2) as attrition_rate
from hr_raw group by jobrole,overtime order by attrition_rate desc;

select department,businesstravel,
count(*) as cnt ,sum(attrition_flag) as attrited,
round(100*sum(attrition_flag) /count(*),2) as attrition_rate
from hr_raw group by department ,businesstravel order by department ,attrition_rate desc;

select jobrole,joblevel,
count(*) as cnt ,
round(avg(monthlyincome),0) as avg_income,
min(monthlyincome) as min_income,
max(monthlyincome) as max_income
from hr_raw group by jobrole ,joblevel order by jobrole ,joblevel ;

select PerformanceRating,
count(*) as cnt ,
round(avg(percentsalaryhike),0) as avg_hike,
min(percentsalaryhike) as min_hike,
max(percentsalaryhike) as max_hike
from hr_raw group by PerformanceRating order by PerformanceRating ;

select MaritalStatus, OverTime,
count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by MaritalStatus, OverTime order by  MaritalStatus, OverTime ;


select Department, TrainingTimesLastYear,
count(*) as cnt ,
sum(attrition_flag) as attrited,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by Department, TrainingTimesLastYear 
order by Department, TrainingTimesLastYear ;

select StockOptionLevel, JobLevel,
count(*) as cnt ,
avg(Monthlyincome) as avg_income,
round(100*sum(attrition_flag)/count(*),2) as attrition_rate
from hr_raw group by StockOptionLevel, JobLevel
order by StockOptionLevel, JobLevel ;

select department,gender,
round(avg(dailyrate),0) as avg_daily_rate,
round(avg(HourlyRate),0) as avg_HourlyRate,
round(avg(MonthlyIncome),0) as avg_MonthlyIncome,
round(avg(MonthlyRate),0) as avg_MonthlyRate,
count(*) as employees from hr_raw
group by department,gender order by department,gender;


delimiter $$
create procedure sp_create_hr_attrition_summary()
begin
    drop view if exists vw_hr_attrition_summary;
    create view vw_hr_attrition_summary as
    select department,jobrole,gender,agegroup,maritalstatus,businesstravel,overtime,
        salaryslab,joblevel,
        case environmentsatisfaction
            when 1 then 'low'
            when 2 then 'medium'
            when 3 then 'high'
            when 4 then 'very high'
        end as envsatlabel,
        case jobsatisfaction
            when 1 then 'low'
            when 2 then 'medium'
            when 3 then 'high'
            when 4 then 'very high'
        end as jobsatlabel,
        case worklifebalance
            when 1 then 'bad'
            when 2 then 'good'
            when 3 then 'better'
            when 4 then 'best'
        end as wlblabel,
        count(*) as total_employees,
        sum(attrition_flag) as attrited,
        round(
            100 * sum(attrition_flag) / count(*),
            2
        ) as attrition_rate_pct,
        round(avg(monthlyincome),0) as avg_monthly_income,
        round(avg(dailyrate),0) as avg_daily_rate,
        round(avg(hourlyrate),0) as avg_hourly_rate,
        round(avg(age),1) as avg_age,
        round(avg(yearsatcompany),1) as avg_tenure,
        round(avg(totalworkingyears),1) as avg_total_exp,
        round(avg(yearssincelastpromotion),1)
            as avg_yrs_since_promo,
        round(avg(percentsalaryhike),1)
            as avg_hike_pct,
        round(avg(trainingtimeslastyear),1)
            as avg_training
    from hr_raw
    group by department,jobrole,gender,agegroup,maritalstatus,businesstravel,
        overtime,salaryslab,joblevel,environmentsatisfaction,jobsatisfaction,
        worklifebalance;

end $$
delimiter ;

CALL sp_create_hr_attrition_summary();
select * from  vw_hr_attrition_summary ;





































