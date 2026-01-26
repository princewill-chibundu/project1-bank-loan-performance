# Business Questions — Project 1: Bank Loan Performance Analysis

## Dataset Context
This project analyzes a simulated banking dataset with five core tables:

- `customers`: customer profile attributes (credit score, employment status, DOB, etc.)
- `accounts`: customer banking relationship (account status, balances)
- `loans`: loan contract details (loan amount, status, payments missed, dates)
- `transactions`: loan-related payments and other cash movements (transaction date, type, amount)
- `defaults`: default event records (days past due, recovery status, exposure at default)

---

## Key Business Questions

### 1) Which loan products have the highest default risk?
**Business value:**  
Identifies product types contributing most to portfolio losses and provisioning pressure.

**How we answer it (SQL):**
- Normalize `loan_type` values to avoid duplicated categories
- Define default events using standardized `loan_status`
- Compute:
  - Default rate by **count**
  - Default rate by **exposure** (amount-weighted)

Script: `sql/02_product_default_rate.sql`

---

### 2) How does default risk change over time?
**Business value:**  
Shows whether risk is increasing, stabilizing, or spiking across origination cohorts—useful for underwriting review and risk appetite decisions.

**How we answer it (SQL):**
- Group loans by origination cohort month
- Track default rates and exposure-weighted default rates over time

Script: `sql/03_risk_over_time.sql`

---

### 3) Which customer segments contribute most to risk?
**Business value:**  
Supports targeted mitigation strategies such as restructuring, pay-down campaigns, customer monitoring, and credit policy changes.

**How we answer it (SQL):**
- Segment customers by:
  - Credit score band
  - Employment status
  - Age band (derived from date of birth)
- Link loans to customers using a transaction-derived bridge where loan customer IDs are missing
- Report linkage coverage to ensure results are not misleading

Script: `sql/04_customer_segment_risk.sql`

---

## Important Note on Data Integrity
A significant portion of loan records contains missing customer identifiers, limiting customer-level risk analysis.  
This project explicitly quantifies that limitation and uses transaction-based linkage where possible.

Script: `sql/01_data_quality_checks.sql`
