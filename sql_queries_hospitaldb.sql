
--Hard questions

--Show all of the patients grouped into weight groups. Show the total amount of patients in each weight group. Order the list by the weight group decending.
--For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.
SELECT 
count(*) as patients_group,
floor(weight/10)*10 as weight_grup
from patients
group by weight_grup
order by weight_grup desc

--Show patient_id, weight, height, isObese from the patients table. Display isObese as a boolean 0 or 1.
--Obese is defined as weight(kg)/(height(m)2) >= 30. weight is in units kg. height is in units cm.
SELECT patient_id,  weight, height,
case
	when weight/power((height/100.0),2) >= 30
		then 1
	else 0
end as isObese
from patients

--Show patient_id, first_name, last_name, and attending doctor's specialty. Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
--Check patients, admissions, and doctors tables for required information.
SELECT patients.patient_id,  patients.first_name,
patients.last_name, doctors.specialty
from patients 
join admissions on admissions.patient_id = patients.patient_id
join doctors on admissions.attending_doctor_id = doctors.doctor_id
where diagnosis = 'Epilepsy' and doctors.first_name = 'Lisa'

--All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
--The password must be the following, in order: 1. patient_id 2. the numerical length of patient's last_name 3. year of patient's birth_date
select distinct(patients.patient_id), 
concat(patients.patient_id, len(last_name),year(birth_date))
from patients
join admissions on  patients.patient_id  = admissions.patient_id

--Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
--Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
select 
case when patient_id%2 = 0 then 'Yes'
else 'No'
end as insurance,
(case when patient_id%2 = 0 then count(*)*10
 else count(*)*50 end)
from admissions
group by insurance

--Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name
select province_name
from patients
join province_names on patients.province_id = province_names.province_id
group by province_name
having Sum(gender = 'M') > sum(gender = 'F')

--For each day display the total amount of admissions on that day. Display the amount changed from the previous date.
SELECT admission_date, count(admission_date),
count(admission_date) -
lag(count(admission_date))
over(order by admission_date asc)
FROM admissions
group by admission_date

--We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
-- First_name contains an 'r' after the first two letters.
-- Identifies their gender as 'F'
-- Born in February, May, or December
-- Their weight would be between 60kg and 80kg
-- Their patient_id is an odd number
-- They are from the city 'Kingston'
select *
from patients
where first_name like '__r%%'
and gender = 'F' and month(birth_date) in (2,5,12)
and weight between 60 and 80
and patient_id%2 != 0 and city = 'Kingston'

--Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.
SELECT CONCAT(
    ROUND(
      (
        SELECT COUNT(*)
        FROM patients
        WHERE gender = 'M'
      ) / CAST(COUNT(*) as float),
      4
    ) * 100,
    '%'
  ) as percent_of_male_patients
FROM patients;

--Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.
SELECT province_name
from province_names
order by
(case when province_name = 'Ontario' then 0 else 1 end),
province_name

--We need a breakdown for the total amount of admissions each doctor has started each year. Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.
SELECT
  d.doctor_id as doctor_id,
  CONCAT(d.first_name,' ', d.last_name) as doctor_name,
  d.specialty,
  YEAR(a.admission_date) as selected_year,
  COUNT(*) as total_admissions
FROM doctors as d
  LEFT JOIN admissions as a ON d.doctor_id = a.attending_doctor_id
GROUP BY
  doctor_name,
  selected_year
ORDER BY doctor_id, selected_year








--Medium Questions

--Show unique birth years from patients and order them by ascending.
select distinct year(birth_date) as birth_year
from patients
order by birth_date asc

--Show unique first names from the patients table which only occurs once in the list.
--For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. 
--If only 1 person is named 'Leo' then include them in the output.
select first_name
from patients
group by first_name
having count(first_name) = 1

--Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
select patient_id, first_name
from patients
where first_name like 's____%s'

--Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'. Primary diagnosis is stored in the admissions table.
select patients.patient_id,  first_name, last_name
from patients 
inner join admissions 
on patients.patient_id= admissions.patient_id
where admissions.diagnosis = 'Dementia'

--Display every patient's first_name. Order the list by the length of each name and then by alphabetically.
select  first_name
from patients 
order by len(first_name), first_name

--Show the total amount of male patients and the total amount of female patients in the patients table.
--Display the two results in the same row.
Select 
   (select count(gender)
   from patients
   where gender = 'F') as female_patients,
  (select  count(gender)
   from patients 
   where gender = 'M') as male_patients

--Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. 
--Show results ordered ascending by allergies then by first_name then by last_name.
select first_name, last_name, allergies
from patients
where allergies in ('Penicillin','Morphine')
order by allergies, first_name, last_name asc

--Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.
select patient_id, diagnosis
from admissions
group by patient_id, diagnosis
having count(*) > 1

--Show the city and the total number of patients in the city. Order from most to least patients and then by city name ascending.
select city, count(patient_id) as total_patients
from patients
group by city
order by total_patients desc, city asc

--Show first name, last name and role of every person that is either patient or doctor. The roles are either "Patient" or "Doctor"
select first_name, last_name, 'Patient' as role
from patients
union all
select first_name, last_name, 'Doctor' as role
from doctors

--Show all allergies ordered by popularity. Remove NULL values from query.
select allergies, count(allergies) as total_diagnosis
from patients
where allergies is not null
group by allergies
order by count(*) desc

--Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
select first_name, last_name, birth_date
from patients
where year(birth_date) >= 1970 and year(birth_date) <= 1979
order by birth_date asc

--We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. Order the list by the first_name in decending order EX: SMITH,jane
select concat(upper(last_name), ',', lower(first_name))
from patients
order by first_name desc

--Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
select province_id, (sum(height)) as mew
from patients
group by province_id 
having mew >= 7000

--Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'
select (max(weight)-miN(weight)) as mew
from patients
where last_name = 'Maroni'

--Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.
select day(admission_date) as day_number, 
count(patient_id)as number_ad
from admissions
group by day_number
order by count(patient_id) desc

--Show all columns for patient_id 542's most recent admission_date.
select *
from admissions
where patient_id = 542
order by admission_date desc
limit 1

--Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
--1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
--2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
select patient_id, attending_doctor_id, diagnosis
from admissions
where
(patient_id%2 != 0 and attending_doctor_id in (1, 5 , 19))
or 

(attending_doctor_id like '%2%' and len(patient_id) = 3)

--Show first_name, last_name, and the total number of admissions attended for each doctor. Every admission has been attended by a doctor.
select first_name, last_name, count(attending_doctor_id)
from admissions
join doctors
on admissions.attending_doctor_id=doctors.doctor_id
group by attending_doctor_id

--For each doctor, display their id, full name, and the first and last admission date they attended.
select doctor_id, 
concat(first_name, ' ', last_name),
min(admission_date), max(admission_date)
from doctors d
join admissions a
on a.attending_doctor_id=d.doctor_id
group by doctor_id
order by doctor_id asc

--Display the total amount of patients for each province. Order by descending.
SELECT province_name, count(patient_id) as patcount
FROM province_names pn
join patients p 
on p.province_id= pn.province_id
group by province_name
order by patcount desc

--For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem.
Select concat (patients.first_name, ' ', patients.last_name),
diagnosis, 
concat(doctors.first_name, ' ', doctors.last_name)
from admissions a 
join patients on a.patient_id = patients.patient_id
join doctors on a.attending_doctor_id = doctors.doctor_id

--display the first name, last name and number of duplicate patients based on their first name and last name.
--Ex: A patient with an identical name can be considered a duplicate.
Select first_name, last_name,
count(*)
from patients
group by first_name, last_name
having count(*) > 1

--Display patient's full name, height in the units feet rounded to 1 decimal, weight in the unit pounds rounded to 0 decimals, birth_date, gender non abbreviated.
--Convert CM to feet by dividing by 30.48. Convert KG to pounds by multiplying by 2.205.
select concat(first_name, ' ', last_name), 
round((height/30.48),1), round((weight*2.205),0),
birth_date, 
case when gender = 'M' then 'Male'
else 'Female'
end as gender
from patients

--Show patient_id, first_name, last_name from patients whose does not have any records in the admissions table. (Their patient_id does not exist in any admissions.patient_id rows.)
select patient_id, first_name, last_name
from patients
where patient_id 
not in 
(select admissions.patient_id from admissions)

--Display a single row with max_visits, min_visits, average_visits where the maximum, minimum and average number of admissions per day is calculated. Average is rounded to 2 decimal places.
select max(no_of_ads), min(no_of_ads), 
round(avg(no_of_ads),2)
from
(select admission_date, count(admission_date) as no_of_ads
from admissions
group by admission_date)







--Easy Questions

--Show first name, last name, and gender of patients whose gender is 'M'
SELECT first_name,last_name,gender FROM patients
where gender= 'M'

--Show first name and last name of patients who does not have allergies. (null)
SELECT first_name,last_name FROM patients
where allergies is null

--Show first name of patients that start with the letter 'C'
SELECT first_name FROM patients
where first_name like 'C%'

--Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)
SELECT first_name, last_name FROM patients
where weight >= 100 and weight <= 120

--Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'
update patients
set allergies = 'NKA'
where allergies is null

--Show first name and last name concatinated into one column to show their full name.
select concat(first_name,' ', last_name) as 'full name' from patients

--Show first name, last name, and the full province name of each patient. Example: 'Ontario' instead of 'ON'
select p.first_name, p.last_name, province_name from patients p
left join province_names pn
on p.province_id= pn.province_id

--Show how many patients have a birth_date with 2010 as the birth year.
select count(*)
from patients
where year(birth_date) = 2010

--Show the first_name, last_name, and height of the patient with the greatest height.
select first_name, last_name, height 
from patients
order by height desc
limit 1

--Show all columns for patients who have one of the following patient_ids: 1,45,534,879,1000
select *
from patients
where patient_id in (1,45,534,879,1000)

--Show all the columns from admissions where the patient was admitted and discharged on the same day.
select * 
from admissions
where admission_date = discharge_date

--Show the patient id and the total number of admissions for patient_id 579.
select patient_id, count(*)
from admissions
where patient_id = '579'

--Based on the cities that our patients live in, show unique cities that are in province_id 'NS'.
select distinct city
from patients
where province_id = 'NS'

--Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70
select first_name, last_name, birth_date
from patients
where height > 160 and weight > 70

--Write a query to find list of patients first_name, last_name, and allergies where allergies are not null and are from the city of 'Hamilton'
select first_name, last_name, allergies
from patients
where allergies is not null and city = 'Hamilton'


