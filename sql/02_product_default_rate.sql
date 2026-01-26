-- ============================================================
-- 02_product_default_rate.sql
-- Project 1 — Bank Loan Performance Analysis
--
-- Business Question 1:
-- Which loan products have the highest default rate?
--
-- Why this matters:
-- Product-level default rates help credit teams identify which
-- loan products are driving portfolio risk and provisioning needs.
--
-- Key Data Notes (observed in this dataset):
-- 1) loan_type values are not standardized (case/format issues),
--    so we normalize using LOWER(TRIM()).
-- 2) loan_status uses multiple labels (e.g., 'Default', 'Charged Off',
--    'Charge-off'), so we normalize and define a default event using
--    a controlled set of labels.
--
-- Default Definition (practical banking proxy):
-- Default event = loan_status_clean IN ('default', 'charged off', 'charge-off')
--
-- Outputs:
-- A) Default rate by COUNT (loan volume perspective)
-- B) Default rate by EXPOSURE (money-weighted perspective)
-- ============================================================

-- A) Default rate by COUNT
SELECT
  LOWER(TRIM(loan_type)) AS loan_type_clean,
  COUNT(*) AS total_loans,
  SUM(
    CASE
      WHEN LOWER(TRIM(loan_status)) IN ('default', 'charged off', 'charge-off')
      THEN 1 ELSE 0
    END
  ) AS defaulted_loans,
  ROUND(
    100.0 * SUM(
      CASE
        WHEN LOWER(TRIM(loan_status)) IN ('default', 'charged off', 'charge-off')
        THEN 1 ELSE 0
      END
    ) / COUNT(*),
    2
  ) AS default_rate_pct
FROM loan.loans
GROUP BY loan_type_clean
ORDER BY default_rate_pct DESC;

-- ------------------------------------------------------------

-- B) Default rate by EXPOSURE (loan_amount-weighted)
SELECT
  LOWER(TRIM(loan_type)) AS loan_type_clean,
  SUM(loan_amount) AS total_exposure,
  SUM(
    CASE
      WHEN LOWER(TRIM(loan_status)) IN ('default', 'charged off', 'charge-off')
      THEN loan_amount ELSE 0
    END
  ) AS defaulted_exposure,
  ROUND(
    100.0 * SUM(
      CASE
        WHEN LOWER(TRIM(loan_status)) IN ('default', 'charged off', 'charge-off')
        THEN loan_amount ELSE 0
      END
    ) / NULLIF(SUM(loan_amount), 0),
    2
  ) AS exposure_default_rate_pct
FROM loan.loans
GROUP BY loan_type_clean
ORDER BY exposure_default_rate_pct DESC;

-- ------------------------------------------------------------
-- Optional: Include "Delinquent" as "At-Risk" (not default, but warning)
-- This helps separate true defaults from early deterioration.
-- ------------------------------------------------------------
SELECT
  LOWER(TRIM(loan_type)) AS loan_type_clean,
  COUNT(*) AS total_loans,
  SUM(CASE WHEN LOWER(TRIM(loan_status)) IN ('delinquent') THEN 1 ELSE 0 END) AS delinquent_loans,
  ROUND(
    100.0 * SUM(CASE WHEN LOWER(TRIM(loan_status)) IN ('delinquent') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS delinquency_rate_pct
FROM loan.loans
GROUP BY loan_type_clean
ORDER BY delinquency_rate_pct DESC;
