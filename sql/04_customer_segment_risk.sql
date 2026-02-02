-- ============================================================
-- 04_customer_segment_risk.sql
-- Project 1 — Bank Loan Performance Analysis (DuckDB + SQL)
--
-- Business Question 3:
-- Which customer segments contribute most to portfolio risk?
--
-- Design Goal:
-- This script is SELF-CONTAINED (no dependency on running other scripts first).
-- It creates/replaces required views before running segment analysis.
--
-- Key Data Reality:
-- Many loans have missing customer_id in loan.loans.
-- We recover linkage using loan payment transactions (loan.transactions).
--
-- Default Definition (standardized):
-- loan_status_clean IN ('default', 'charged off', 'charge-off')
-- ============================================================


-- ============================================================
-- 0) Create required "clean" and "bridge" views (self-contained)
-- ============================================================

-- A) Cleaned loans view: normalize loan_type and loan_status
CREATE OR REPLACE VIEW loan.v_loans_clean AS
SELECT
  loan_id,
  account_id,
  customer_id,
  LOWER(TRIM(loan_type)) AS loan_type_clean,
  LOWER(TRIM(loan_status)) AS loan_status_clean,
  loan_amount,
  interest_rate,
  term_months,
  origination_date,
  maturity_date,
  outstanding_balance,
  monthly_payment,
  payments_made,
  payments_missed
FROM loan.loans;

-- B) Cleaned transactions view: normalize transaction_type
CREATE OR REPLACE VIEW loan.v_transactions_clean AS
SELECT
  transaction_id,
  account_id,
  customer_id,
  loan_id,
  LOWER(TRIM(transaction_type)) AS transaction_type_clean,
  transaction_date,
  transaction_amount
FROM loan.transactions;

-- C) Loan → Customer bridge using most recent loan payment transaction per loan_id
CREATE OR REPLACE VIEW loan.v_loan_customer_bridge AS
SELECT
  loan_id,
  ARG_MAX(customer_id, transaction_date) AS customer_id_from_txn,
  COUNT(*) AS payment_txn_count
FROM loan.v_transactions_clean
WHERE loan_id IS NOT NULL
  AND customer_id IS NOT NULL
  AND transaction_type_clean = 'loan payment'
GROUP BY loan_id;

-- D) Enriched loans view with best-available customer_id
CREATE OR REPLACE VIEW loan.v_loans_enriched AS
SELECT
  l.*,
  COALESCE(l.customer_id, b.customer_id_from_txn) AS customer_id_best
FROM loan.v_loans_clean l
LEFT JOIN loan.v_loan_customer_bridge b
  ON l.loan_id = b.loan_id;

-- E) Convenience view: only loans that are linked to a customer_id_best
CREATE OR REPLACE VIEW loan.v_loans_linked AS
SELECT
  loan_id,
  loan_type_clean,
  loan_status_clean,
  loan_amount,
  customer_id_best
FROM loan.v_loans_enriched
WHERE customer_id_best IS NOT NULL
  AND TRIM(customer_id_best) <> '';


-- ============================================================
-- 1) Linkage coverage disclosure (critical)
-- ============================================================

SELECT
  COUNT(*) AS total_loans,
  SUM(CASE WHEN customer_id_best IS NOT NULL AND TRIM(customer_id_best) <> '' THEN 1 ELSE 0 END) AS loans_linked_to_customer,
  ROUND(
    100.0 * SUM(CASE WHEN customer_id_best IS NOT NULL AND TRIM(customer_id_best) <> '' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_linked
FROM loan.v_loans_enriched;


-- ============================================================
-- 2) Build customer segments (credit band, employment status, age band)
-- ============================================================

WITH customer_segments AS (
  SELECT
    customer_id,
    employment_status,
    credit_score,
    DATE_DIFF('year', date_of_birth, CURRENT_DATE) AS age,
    CASE
      WHEN credit_score >= 750 THEN 'Excellent (750+)'
      WHEN credit_score >= 700 THEN 'Good (700-749)'
      WHEN credit_score >= 650 THEN 'Fair (650-699)'
      ELSE 'Poor (<650)'
    END AS credit_band,
    CASE
      WHEN DATE_DIFF('year', date_of_birth, CURRENT_DATE) < 30 THEN 'Under 30'
      WHEN DATE_DIFF('year', date_of_birth, CURRENT_DATE) BETWEEN 30 AND 44 THEN '30–44'
      WHEN DATE_DIFF('year', date_of_birth, CURRENT_DATE) BETWEEN 45 AND 59 THEN '45–59'
      ELSE '60+'
    END AS age_band
  FROM loan.customers
)

-- ============================================================
-- 3) Risk by Credit Score Band (COUNT + EXPOSURE)
-- ============================================================
SELECT
  cs.credit_band,
  COUNT(*) AS linked_loans,
  SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) AS defaulted_loans,
  ROUND(
    100.0 * SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS default_rate_pct,
  SUM(l.loan_amount) AS total_exposure,
  SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN l.loan_amount ELSE 0 END) AS defaulted_exposure
FROM loan.v_loans_linked l
JOIN customer_segments cs
  ON l.customer_id_best = cs.customer_id
GROUP BY cs.credit_band
ORDER BY default_rate_pct DESC;


-- ============================================================
-- 4) Risk by Employment Status (COUNT + EXPOSURE)
-- ============================================================
WITH customer_segments AS (
  SELECT
    customer_id,
    employment_status,
    credit_score,
    CASE
      WHEN credit_score >= 750 THEN 'Excellent (750+)'
      WHEN credit_score >= 700 THEN 'Good (700-749)'
      WHEN credit_score >= 650 THEN 'Fair (650-699)'
      ELSE 'Poor (<650)'
    END AS credit_band
  FROM loan.customers
)
SELECT
  cs.employment_status,
  COUNT(*) AS linked_loans,
  SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) AS defaulted_loans,
  ROUND(
    100.0 * SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS default_rate_pct,
  SUM(l.loan_amount) AS total_exposure,
  SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN l.loan_amount ELSE 0 END) AS defaulted_exposure
FROM loan.v_loans_linked l
JOIN customer_segments cs
  ON l.customer_id_best = cs.customer_id
GROUP BY cs.employment_status
ORDER BY default_rate_pct DESC;


-- ============================================================
-- 5) Risk by Age Band (COUNT + EXPOSURE)
-- ============================================================
WITH customer_segments AS (
  SELECT
    customer_id,
    DATE_DIFF('year', date_of_birth, CURRENT_DATE) AS age,
    CASE
      WHEN DATE_DIFF('year', date_of_birth, CURRENT_DATE) < 30 THEN 'Under 30'
      WHEN DATE_DIFF('year', date_of_birth, CURRENT_DATE) BETWEEN 30 AND 44 THEN '30–44'
      WHEN DATE_DIFF('year', date_of_birth, CURRENT_DATE) BETWEEN 45 AND 59 THEN '45–59'
      ELSE '60+'
    END AS age_band
  FROM loan.customers
)
SELECT
  cs.age_band,
  COUNT(*) AS linked_loans,
  SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) AS defaulted_loans,
  ROUND(
    100.0 * SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS default_rate_pct,
  SUM(l.loan_amount) AS total_exposure,
  SUM(CASE WHEN l.loan_status_clean IN ('default','charged off','charge-off') THEN l.loan_amount ELSE 0 END) AS defaulted_exposure
FROM loan.v_loans_linked l
JOIN customer_segments cs
  ON l.customer_id_best = cs.customer_id
GROUP BY cs.age_band
ORDER BY default_rate_pct DESC;
