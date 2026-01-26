-- ============================================================
-- 01_data_quality_checks.sql
-- Purpose:
-- Identify data quality issues that materially impact
-- credit risk analysis, provisioning, and executive decisions.
--
-- These checks explain WHY certain analyses (customer-level risk,
-- early intervention strategies) are constrained in this dataset.
-- ============================================================

-- 1. Customer ID completeness in loans table
SELECT
  COUNT(*) AS total_loans,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS loans_missing_customer_id,
  ROUND(
    100.0 * SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_missing_customer_id
FROM loan.loans;

-- Business Impact:
-- Missing customer_id prevents customer-level risk aggregation,
-- restructuring decisions, and targeted collections strategies.


-- 2. Loan status value inconsistencies
SELECT
  loan_status,
  COUNT(*) AS row_count
FROM loan.loans
GROUP BY loan_status
ORDER BY row_count DESC;

-- Business Impact:
-- Inconsistent status labels (e.g. 'charged off', 'charge-off')
-- can understate default exposure if not standardized.


-- 3. Transaction type inconsistencies
SELECT
  transaction_type,
  COUNT(*) AS row_count
FROM loan.transactions
GROUP BY transaction_type
ORDER BY row_count DESC;

-- Business Impact:
-- Mixed casing and naming ('Loan Payment', 'loan payment')
-- causes undercounting of repayments and distorted trend analysis.


-- 4. Loans with high missed payments but still marked active/current
SELECT
  loan_id,
  loan_status,
  payments_missed
FROM loan.loans
WHERE LOWER(TRIM(loan_status)) IN ('active', 'current')
  AND payments_missed >= 2
ORDER BY payments_missed DESC;

-- Business Impact:
-- These loans represent early-warning signals.
-- Without analytics, they may roll into default unnoticed,
-- increasing provisioning shocks.


-- 5. Customer coverage recovered via transaction bridge
SELECT
  COUNT(*) AS total_loans,
  SUM(CASE WHEN customer_id_best IS NOT NULL THEN 1 ELSE 0 END) AS loans_with_customer_after_bridge,
  ROUND(
    100.0 * SUM(CASE WHEN customer_id_best IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_customer_recovered
FROM loan.v_loans_enriched;

-- Business Impact:
-- Demonstrates how analytics can partially recover
-- decision-making capability even with imperfect source data.
