-- ============================================================
-- 03_risk_over_time.sql
-- Project 1 — Bank Loan Performance Analysis
--
-- Business Question 2:
-- How does default risk change over time?
--
-- Approach:
-- Use origination_date to create monthly cohorts and calculate:
-- 1) Default rate by count (loan volume)
-- 2) Default rate by exposure (loan_amount-weighted)
--
-- Default Definition:
-- loan_status_clean IN ('default', 'charged off', 'charge-off')
--
-- Why cohorts matter:
-- Cohorts help identify periods where underwriting quality,
-- risk appetite, or macro conditions increased portfolio risk.
-- ============================================================

-- A) Default rate trend by origination month (COUNT-based)
SELECT
  DATE_TRUNC('month', origination_date) AS cohort_month,
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
GROUP BY cohort_month
ORDER BY cohort_month;

-- ------------------------------------------------------------

-- B) Default exposure trend by origination month (EXPOSURE-based)
SELECT
  DATE_TRUNC('month', origination_date) AS cohort_month,
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
GROUP BY cohort_month
ORDER BY cohort_month;

-- ------------------------------------------------------------
-- Optional: Track delinquency trend (early warning, not default)
-- ------------------------------------------------------------
SELECT
  DATE_TRUNC('month', origination_date) AS cohort_month,
  COUNT(*) AS total_loans,
  SUM(CASE WHEN LOWER(TRIM(loan_status)) = 'delinquent' THEN 1 ELSE 0 END) AS delinquent_loans,
  ROUND(
    100.0 * SUM(CASE WHEN LOWER(TRIM(loan_status)) = 'delinquent' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS delinquency_rate_pct
FROM loan.loans
GROUP BY cohort_month
ORDER BY cohort_month;
