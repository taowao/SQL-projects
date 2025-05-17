-- Exploratory Data Analysis on the Company Layoffs Dataset

-- For reference use
Select *
from layoffs_staging2;

-- 1. Show the max total_laid_off value and the max percentage_laid_off value
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- 2. Show which company has the max total_laid_off value
--    *Using subqueries
select company
from layoffs_staging2
where total_laid_off = (select max(total_laid_off)
						from layoffs_staging2)
;


-- 3. Group all the rows with the same company together and calculate the sum of the total_laid_off on each. 
--    Then show the list of companies and sums, ordering the sums in desc order.
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- 4. Look at date ranges / time period
select min(`date`), max(`date`)
from layoffs_staging2;

-- 5. What industry got hit the most / had the most layoffs during this time period?
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;


-- 6. Similarly, which countries had the most layoffs during this time period?
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- 7. Similarly, which year had the most layoffs?
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- 8. What are the layoff numbers for each stage of companies?
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- 9. Calculating ROLLING TOTAL/SUM of total_laid_off
select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1;

with rolling_sum as 
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1
)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total
from rolling_sum
;



-- 10. List the top 5 companies that let off the most employees in each year
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
;

with Company_Year (company, years, total_laid_off) as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
,
Company_Year_Rank as 
(select *, dense_rank() over(
partition by years order by total_laid_off desc
) as ranking
from Company_Year
where years is not null
)

select *
from Company_Year_Rank
where ranking <= 5
;




