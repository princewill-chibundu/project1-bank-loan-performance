-- ============================================================
-- 04_customer_segment_risk.sql
-- Project 1 — Bank Loan Performance Analysis
--
-- Business Question 3:
-- Which customer segments contribute most to risk?
--
-- Key Data Reality:
-- loan.loans.customer_id contains many NULL values, limiting customer-level analysis.
-- To enable segmentation, we use loan.v_loans_enriched.customer_id_best, which is
-- recovered via transaction-based linkage (loan payment transactions).
--
-- Segments:
-- 1) Credit score band
-- 2) Employment status
-- 3) (Optional) Age band derived from date_of_birth
--
-- Default Definition:
-- loan_status_clean IN ('default','charged off','charge-off')
-- ============================================================

-- ------------------------------------------------------------
-- A) Linkage coverage disclosure (very important)
-- ------------------------------------------------------------
SELECT
  COUNT(*) AS total_loans,
  SUM(CASE WHEN customer_id_best IS NOT NULL AND TRIM(customer_id_best) <> '' THEN 1 ELSE 0 END) AS loans_linked_to_customer,
  ROUND(
    100.0 * SUM(CASE WHEN customer_id_best IS NOT NULL AND TRIM(customer_id_best) <> '' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_linked
FROM loan.v_loans_enriched;

-- ------------------------------------------------------------
-- B) Define customer segments (credit band + employment)
-- Note: adjust field names if needed (you have credit_score and employment_status)
-- ------------------------------------------------------------
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
),

loans_linked AS (
  SELECT
    loan_id,
    loan_type_clean,
    loan_status_clean,
    loan_amount,
    customer_id_best
  FROM loan.v_loans_enriched
  WHERE customer_id_best IS NOT NULL
    AND TRIM(customer_id_best) <> ''
)

-- ------------------------------------------------------------
-- C) Risk by Credit Score Band (COUNT + EXPOSURE)
-- ------------------------------------------------------------
SELECT
  cs.credit_band,
  COUNT(*) AS linked_loans,
  SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) AS defaulted_loans,
  ROUND(
    100.0 * SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS default_rate_pct,
  SUM(ll.loan_amount) AS total_exposure,
  SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN ll.loan_amount ELSE 0 END) AS defaulted_exposure
FROM loans_linked ll
JOIN customer_segments cs
  ON ll.customer_id_best = cs.customer_id
GROUP BY cs.credit_band
ORDER BY default_rate_pct DESC;

-- ------------------------------------------------------------
-- D) Risk by Employment Status (COUNT + EXPOSURE)
-- ------------------------------------------------------------
SELECT
  cs.employment_status,
  COUNT(*) AS linked_loans,
  SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) AS defaulted_loans,
  ROUND(
    100.0 * SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS default_rate_pct,
  SUM(ll.loan_amount) AS total_exposure,
  SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN ll.loan_amount ELSE 0 END) AS defaulted_exposure
FROM loans_linked ll
JOIN customer_segments cs
  ON ll.customer_id_best = cs.customer_id
GROUP BY cs.employment_status
ORDER BY default_rate_pct DESC;

-- ------------------------------------------------------------
-- E) (Optional) Risk by Age Band (COUNT + EXPOSURE)
-- ------------------------------------------------------------
SELECT
  cs.age_band,
  COUNT(*) AS linked_loans,
  SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) AS defaulted_loans,
  ROUND(
    100.0 * SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS default_rate_pct,
  SUM(ll.loan_amount) AS total_exposure,
  SUM(CASE WHEN ll.loan_status_clean IN ('default','charged off','charge-off') THEN ll.loan_amount ELSE 0 END) AS defaulted_exposure
FROM loans_linked ll
JOIN customer_segments cs
  ON ll.customer_id_best = cs.customer_id
GROUP BY cs.age_band
ORDER BY default_rate_pct DESC;
