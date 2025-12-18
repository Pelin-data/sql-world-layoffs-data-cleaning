-- =====================================================
-- WORLD LAYOFFS | SQL DATA CLEANING
-- =====================================================
-- This script cleans the World Layoffs dataset using a staging-based approach in MySQL.

-- RAW DATA
SELECT *
FROM layoffs;

-- =====================================================
-- STAGING TABLE
-- =====================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- =====================================================
-- REMOVING DUPLICATES
-- =====================================================

-- Check duplicates using ROW_NUMBER
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, total_laid_off,
                 percentage_laid_off, `date`, stage,
                 country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- =====================================================
-- SECOND STAGING TABLE (MySQL does not support DELETE from CTE)
-- =====================================================

CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert data with row_number
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, total_laid_off,
                 percentage_laid_off, `date`, stage,
                 country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Remove duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- =====================================================
-- STANDARDIZING DATA
-- =====================================================

-- Trim company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry names
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- Remove trailing dot in country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- =====================================================
-- DATE CONVERSION
-- =====================================================

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- =====================================================
-- NULL & BLANK HANDLING
-- =====================================================

-- Convert blank industry to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing industry using self join
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
 AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Remove rows with no layoff information
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- =====================================================
-- CLEANUP
-- =====================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- FINAL CLEAN DATA
SELECT *
FROM layoffs_staging2;
