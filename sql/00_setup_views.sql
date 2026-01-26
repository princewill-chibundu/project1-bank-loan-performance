-- ============================================================
-- 00_setup_views.sql
-- Purpose:
-- 1) Standardize messy categorical fields (loan_type, loan_status, transaction_type)
-- 2) Create a reliable loan → customer bridge using transactions
--    because loan.loans.customer_id is largely NULL in this dataset.
-- ============================================================

-- Clean loans view
CREATE OR REPLACE VIEW loan.v_loans_clean AS
SELECT
  loan_id,
  account_id,
  customer_id,
  LOWER(TRIM(loan_type)) AS loan_type_clean,
  LOWER(TRIM(loan_status)) AS loan_status_clean,
  loan_type,
  loan_status,
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

-- Clean transactions view
CREATE OR REPLACE VIEW loan.v_transactions_clean AS
SELECT
  transaction_id,
  account_id,
  customer_id,
  loan_id,
  LOWER(TRIM(transaction_type)) AS transaction_type_clean,
  transaction_type,
  transaction_date,
  transaction_amount,
  balance_after_transaction,
  description,
  channel,
  status,
  processed_by,
  created_at
FROM loan.transactions;

-- Loan → Customer bridge (use most recent customer_id observed for each loan_id)
-- We focus on loan payment transactions to improve linkage quality.
CREATE OR REPLACE VIEW loan.v_loan_customer_bridge AS
SELECT
  loan_id,
  ARG_MAX(customer_id, transaction_date) AS customer_id_from_txn,
  COUNT(*) AS txn_rows_for_loan
FROM loan.v_transactions_clean
WHERE loan_id IS NOT NULL
  AND customer_id IS NOT NULL
  AND transaction_type_clean = 'loan payment'
GROUP BY loan_id;

-- Loans enriched with best-available customer_id
CREATE OR REPLACE VIEW loan.v_loans_enriched AS
SELECT
  l.*,
  COALESCE(l.customer_id, b.customer_id_from_txn) AS customer_id_best
FROM loan.v_loans_clean l
LEFT JOIN loan.v_loan_customer_bridge b
  ON l.loan_id = b.loan_id;
