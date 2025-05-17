-- Data Cleaning on Company Layoffs Dataset

-- For reference
select *
from layoffs;

-- 1. REMOVING DUPLICATES
-- 2. STANDARIZE THE DATA
-- 3. Change the null values or blank values
-- 4. Remove any columns

-- 1. Removing duplicates

-- Creating a new table, as we do not want to work on the raw dataset
create table layoffs_staging
like layoffs;

insert into layoffs_staging
select *
from layoffs;




-- USED WINDOW FUNCTIONS TO GROUP ROWS TO FIND THE ROW_NUM

select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;


-- CREATED A CTE TO SHOW DUPLICATES

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;


-- Now we will create a table, where we will show our final results on

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


insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
;


-- For reference
select *
from layoffs_staging2
;

-- For testing
select *
from layoffs_staging2
where company like '100%';


-- We will delete the duplicates on the clean/final table
Delete
from layoffs_staging2
where row_num > 1;


-- 2. Standardizing data

-- Editing the cells in the company column that have spacing problems
select company, trim(company)
from layoffs_staging2
;

update layoffs_staging2
set company = trim(company)
;

-- Editing the cells in the industry column that have duplicates / similar names
select distinct industry
from layoffs_staging2
;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'
;

-- Editing the cells in the country column that have periods after the name

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
where country like 'United States%'
;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%'
;

-- Editing the date column from a text type to a date type

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2
;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
;

alter table layoffs_staging2
modify column `date` date;



-- 3. Modifying NULL values

-- All for examining/testing purposes
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

-- Using self-join to update the blank cells and fill it with content of the non-blank ones.
select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null
;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null
;


-- Finally, deleting the row_num column as it is unneccessary to keep
alter table layoffs_staging2
drop column row_num;





