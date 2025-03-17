-- Exploratary Data Analysis

ALTER TABLE layoff_staging2
MODIFY COLUMN total_laid_off      INT,
MODIFY COLUMN percentage_laid_off FLOAT,
MODIFY COLUMN funds_raised        INT;


-- Looking at Percentage to see how big these layoffs were

SELECT *
FROM layoff_staging2;

SELECT 
	MAX(percentage_laid_off), 
	MIN(percentage_laid_off)
FROM layoff_staging2;

-- Which companies had 1 which is basically 100 percent of they company laid off

SELECT *
FROM layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;

-- Companies with the most Total Layoffs

SELECT 
	company,
	MAX(total_laid_off)
FROM layoff_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Stage with the most Total Layoffs

SELECT 
	stage,
	MAX(total_laid_off)
FROM layoff_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Rolling Total of Layoffs Per Month

SELECT 
	SUBSTRING(`date`, 1, 7) AS `month`,
	SUM(total_laid_off)     AS total_off
FROM layoff_staging2
GROUP BY 1
ORDER BY 1;

-- use CTE
WITH Rolling_Total AS 
(
	SELECT 
	SUBSTRING(`date`, 1, 7) AS `month`,
	SUM(total_laid_off)     AS total_off
	FROM layoff_staging2
	GROUP BY 1
	ORDER BY 1
) 
SELECT 
	`month`,
	total_off,
	SUM(total_off) OVER(ORDER BY `month`) AS rolling_total -- No partition cuz 
FROM Rolling_Total;  					       -- the data has already been grouped in the CTE

-- maximum layoff ranking

SELECT 
	company,
	YEAR(`date`) AS `year`,
	SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, `year`
ORDER BY 3 DESC;

-- CTE 
WITH  company_year AS
(
	SELECT 
	company,
	YEAR(`date`)         AS `year`,
	SUM(total_laid_off)  AS total_off
	FROM layoff_staging2
	GROUP BY company, `year`
	ORDER BY 3 DESC
), 
	company_year_rank AS 
(
	SELECT
	*, 
	DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_off DESC) AS ranking
	FROM company_year
	ORDER BY ranking  	-- Can't use WHERE <= 5 cuz WHERE runs before SELECT 
)			        -- There is no column named 'ranking', So there is no data to use with WHERE <= 5

SELECT *
FROM company_year_rank
WHERE ranking <= 5;


-- Industry with the most layoffs and the quarter and year in which the layoffs peaked

WITH industry_layoffs AS 
(
    SELECT 
        industry,
        YEAR(`date`) 	    AS `year`,
        QUARTER(`date`)     AS `quarter`,
        SUM(total_laid_off) AS total_laid_off_quarter
    FROM layoff_staging2
    GROUP BY industry, `year`, `quarter`
),
	max_layoffs AS    -- Select the industry with the most layoffs
(
    SELECT 
        industry,
        `year`,
        `quarter`,
        total_laid_off_quarter
    FROM industry_layoffs
    ORDER BY total_laid_off_quarter DESC
    LIMIT 1
)

-- Final query to get the industry with the most layoffs and percentage
SELECT 
    max_layoffs.industry,
    max_layoffs.year,
    max_layoffs.quarter,
    max_layoffs.total_laid_off_quarter,
    (max_layoffs.total_laid_off_quarter / 
     (SELECT SUM(total_laid_off) FROM layoff_staging2)) * 100 AS percentage_of_total_layoffs
FROM max_layoffs;

SELECT 
    (SUM(CASE WHEN industry = 'Transportation' THEN total_laid_off ELSE 0 END) / SUM(total_laid_off)) * 100 AS transportation_percentage
FROM 
    layoff_staging2;















  
