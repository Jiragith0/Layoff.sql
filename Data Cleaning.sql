## Data Cleaning 

SELECT *
FROM layoffs; 

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values 
-- 4. Remove Any Columns

-- Duplicate the raw data into a new table

CREATE TABLE layoff_staging
LIKE layoffs;

SELECT *
FROM layoff_staging; -- have columns only

INSERT layoff_staging 
SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- Use Row_number() to find duplicate

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
			 stage, country, funds_raised) AS row_num
FROM layoff_staging;

-- CTEs
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
			 stage, country, funds_raised) AS row_num
FROM layoff_staging

)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- 1. Delete duplicates

CREATE TABLE `layoff_staging2` (  		-- Create new table cuz DELETE can't use with CTE
  `company` text,				-- Add column name 'row_num'
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoff_staging2; -- have columns only

INSERT INTO layoff_staging2  -- Inset data have column 'row_num'
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
			 stage, country, funds_raised) AS row_num
FROM layoff_staging;

DELETE
FROM layoff_staging2
WHERE row_num > 1;

SELECT *
FROM layoff_staging2; -- Nothing duplicates

-- 2. Standardizing data

SELECT company, TRIM(company)  -- Trim
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);


SELECT DISTINCT location  -- Change name
FROM layoff_staging2
ORDER BY 1;

UPDATE layoff_staging2
SET location = 'Førde'
WHERE location LIKE 'F%de';

SELECT * 
FROM layoff_staging2
ORDER BY 1;

UPDATE layoff_staging2
SET industry = 'Hardware'
WHERE industry = 'Transportation' AND company = 'Apple';

SELECT `date`,   	-- Change type date from Text to Date
STR_TO_DATE(`date`, '%Y-%m-%d')
FROM layoff_staging;

UPDATE layoff_staging2     -- Change data of date from Text to Date
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d'); 

ALTER TABLE layoff_staging2		-- Change column date from Text to Date
MODIFY COLUMN  `date` DATE;


-- 3. Null Values or blank values 

SELECT *
FROM layoff_staging2;

UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoff_staging2
SET total_laid_off = NULL 
WHERE total_laid_off = '';

UPDATE layoff_staging2
SET percentage_laid_off = NULL 
WHERE percentage_laid_off = '';

-- 4. Remove Any Columns

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoff_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT *
FROM layoff_staging2;

ALTER TABLE layoff_staging2		-- Delete column
DROP COLUMN row_num;














		 
