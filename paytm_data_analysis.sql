create database paytm
use paytm
CREATE TABLE paytm_data_csv (
        `Transfer_ID` VARCHAR(78),
        `Date_and_Time` VARCHAR(16),
        `Narration` VARCHAR(214),
        `Amount` VARCHAR(78),
        `Type` VARCHAR(1),
        `Reference_no` VARCHAR(78),
        `Available_balance`VARCHAR(78),
        `Beneficiary_Account_number` VARCHAR(40),
        `Beneficiary_name` VARCHAR(38),
        `Remitter_Account_number` VARCHAR(38),
        `Remitter_name` VARCHAR(25),
        `Remarks` VARCHAR(48)
);
drop table paytm_data_csv;
select * from paytm_data_csv;

LOAD DATA INFILE 'D:\\paytm_data_analysis\\paytm_data_csv.csv' into table paytm_data_csv fields terminated by ',' enclosed by '"' lines terminated by '\n' ignore 1 rows;

# total number of transactions
select count(Transfer_ID) from paytm_data_csv;

# start date and last date 
select Date_and_Time from paytm_data_csv;

# a new column created dates from Date_and_Time column and only dates are extracted 
alter table paytm_data_csv
add column dates date  after Date_and_Time;
update paytm_data_csv
set dates=str_to_date(left(Date_and_Time,10),'%d-%m-%Y');

# rows which has 0000 values removed
delete from paytm_data_csv where dates='0000-00-00';

# opening date 
select min(dates) from paytm_data_csv;
# closing date
select max(dates) from paytm_data_csv;


# a new column created timing from Date_and_Time column and only times are extracted 
alter table paytm_data_csv
add column timing time  after dates;
update paytm_data_csv
set timing=right(Date_and_Time,5);

 
# year wise transactions happened
select year(dates),count(Transfer_ID)
from paytm_data_csv
group by year(dates);

# number of transactions done in a day
with cte as(
select timing,
case when timing>= '00:00:00' and timing<='12:00:00' then 'morning'
	 when timing>= '12:01:00' and timing<='18:00:00' then 'evening'
	 when timing>= '18:01:00' and timing<='24:00:00' then 'night'
end as timing_grp
from paytm_data_csv)
select timing_grp,count(timing_grp)
from cte
group by timing_grp
order by count(timing_grp) desc;


# top 5 Beneficiary_names
select Beneficiary_name,count(Transfer_ID)
from paytm_data_csv
group by Beneficiary_name
order by count(Transfer_ID) desc
limit 5;

# top 5 Remitter_names 
select Remitter_name,count(Transfer_ID)
from paytm_data_csv
group by Remitter_name
order by count(Transfer_ID) desc
limit 5;

# percentage distribution of Type column
select Type,count(Type) as total_count,
(count(Type) /(select count(Type) from paytm_data_csv))*100 as pct
from paytm_data_csv
group by Type;

select * from paytm_data_csv;

# avg amount received to beneficiary account
select Beneficiary_name,avg(Amount)
from paytm_data_csv 
group by Beneficiary_name 
order by avg(Amount) desc 
limit 10;

# avg amount sent by remitter account
select Remitter_name,avg(Amount)
from paytm_data_csv 
group by Remitter_name 
order by avg(Amount) desc 
limit 10

