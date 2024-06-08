use world_layoffs;
select * from layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens

create table layoffs_staging
like layoffs;

insert layoffs_staging
select * from layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

select * from layoffs_staging;

-- 1. check for duplicates and remove any

select *,
row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,'data',stage,country,funds_raised_millions)as row_num
from layoffs_staging;

with dupicate_cte as
(
select *,
row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,'data',stage,country,funds_raised_millions)as row_num
from layoffs_staging)

select * from dupicate_cte
where row_num>1;


select * from layoffs_staging
where company="casper";


with dupicate_cte as
(
select *,
row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,'data',stage,country,funds_raised_millions)as row_num
from layoffs_staging)

delete from dupicate_cte
where row_num>1;



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,'data',stage,country,funds_raised_millions)as row_num
from layoffs_staging;

select * from layoffs_staging2
where row_num>1;

delete 
from layoffs_staging2
where row_num>1;


-- 2. standardize data and fix errors


select company,trim(company)
from layoffs_staging2;

-- trim use for remove whitespace


update  layoffs_staging2
set company=trim(company);


select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

select distinct country
from layoffs_staging2
order by 1;



select * from layoffs_staging2
where country like 'united states%';


select distinct country,trim(trailing '.' from country) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country) 
where country like 'united states%';

select * from layoffs_staging2;

select `date` from layoffs_staging2;

select `date` ,
str_to_date (`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date`=str_to_date (`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

-- 3. Look at null values and see what 

select * from  layoffs_staging2
where company like 'Bally%';

select * from  layoffs_staging2
where total_laid_off is null and
percentage_laid_off is null;

update layoffs_staging2
set industry= null
where industry ='';

select * from  layoffs_staging2
where industry is null 
or industry='';



select t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;


update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null 
and t2.industry is not null;

-- 4. remove any columns and rows that are not necessary - few ways

select * from  layoffs_staging2
where total_laid_off is null and
percentage_laid_off is null;


delete from  layoffs_staging2
where total_laid_off is null and
percentage_laid_off is null;


select * from  layoffs_staging2;

alter table layoffs_staging2
drop column row_num;

