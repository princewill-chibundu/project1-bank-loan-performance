# Project 1 — Bank Loan Performance Analysis (SQL + DuckDB)

## Project Overview
This project analyzes a simulated banking loan portfolio to understand **default risk, exposure concentration, and customer-level risk drivers**.

The analysis is designed to answer practical **executive and risk-management questions**, using SQL only (DuckDB), with a strong emphasis on:
- Data quality awareness
- Risk-aware aggregations
- Clear, decision-ready insights

---

## Business Questions
1. **Which loan products have the highest default risk?**  
2. **How does default risk evolve over time?**  
3. **Which customer segments contribute most to portfolio risk?**

---

## Dataset
The following tables are used:
- `loan.customers`
- `loan.accounts`
- `loan.loans`
- `loan.transactions`
- `loan.defaults`

---

## Data Quality Issues & Resolution

This project intentionally reflects **realistic data quality challenges** commonly encountered in banking and regulated financial environments.  
Rather than assuming perfect data, these issues were explicitly identified, documented, and handled in a risk-aware manner.

---

### 1) Missing Customer Identifiers in Loan Records

**Issue:**  
A significant portion of records in the `loans` table contained `NULL` or empty `customer_id` values.

**Why this matters:**  
In a real banking environment, missing loan-to-customer linkage:
- Prevents accurate customer-level risk aggregation
- Limits exposure monitoring and concentration analysis
- Increases operational and governance risk
- Can materially impact provisioning and executive decision-making

**How it was handled:**  
- The issue was explicitly surfaced and quantified in data quality checks  
- A transaction-derived bridge (`customer_id_best`) was created using loan payment transactions to **partially recover customer linkage**
- All customer-segment risk analysis includes **linkage coverage disclosure** to avoid misleading conclusions

**Remaining limitation:**  
Not all loans could be reliably linked to customers. Results were interpreted with this constraint clearly documented.

---

### 2) Inconsistent Loan Product Definitions

**Issue:**  
The `loan_type` field contained inconsistent values due to:
- Mixed letter casing (e.g., `Mortgage` vs `mortgage`)
- Trailing or leading whitespace

**Why this matters:**  
Without normalization, aggregation queries would:
- Treat the same product as multiple distinct categories
- Understate or overstate product-level default risk
- Mislead portfolio and product risk analysis

**How it was resolved:**  
- Loan product values were standardized using `LOWER()` and `TRIM()` functions
- A cleaned product field (`loan_type_clean`) was used consistently across all analyses

---

### 3) Inconsistent Loan Status Values

**Issue:**  
Loan status values were not harmonized (e.g., `Charged Off`, `charge-off`, `charged off`).

**Why this matters:**  
Inconsistent status values can:
- Underreport defaults
- Distort default rates and exposure calculations
- Lead to incorrect risk assessments

**How it was resolved:**  
- Loan status values were normalized into a cleaned status field (`loan_status_clean`)
- Default events were defined using a standardized set of values (e.g., `default`, `charged off`, `charge-off`)

---

### 4) Default Metrics Showing Zero Values

**Issue:**  
Initial default rate calculations returned zero values despite the presence of loan records.

**Why this matters:**  
This can falsely indicate a healthy portfolio and mask underlying risk.

**Root cause:**  
- Defaults were not explicitly encoded in a single consistent field
- Aggregations relied on uncleaned categorical values

**How it was resolved:**  
- Default definitions were standardized
- Queries were rewritten using cleaned status fields
- Exposure-weighted default metrics were introduced to reflect financial impact

---

### 5) Customer Records Without Active Accounts

**Issue:**  
A subset of customers existed in the `customers` table without corresponding records in the `accounts` table.

**Why this matters:**  
This raises important business and governance questions:
- What defines a “customer”?
- Are these prospects, closed relationships, or data artifacts?
- Should they be included in risk and portfolio analytics?

**How it was handled:**  
- LEFT JOINs were used to preserve visibility into unmatched records
- The issue was documented as a **business definition and governance concern**, not silently filtered out

---

## Summary

Data quality challenges were **not treated as errors to be hidden**, but as **risk signals** that directly affect analytics reliability and executive decision-making.

This approach mirrors real-world banking analytics, where:
- Data imperfections are common
- Governance gaps can be more dangerous than modeling gaps
- Transparency is critical for responsible risk management

## Executive Insights (Non-Technical Summary)

### 1️⃣ Loan Products with Highest Risk
After cleaning inconsistent loan type values, **Home Equity loans** show the highest risk across:
- Default rate (count-based)
- Default exposure rate (amount-weighted)

**What this means:**  
Home Equity loans represent the most material risk to the bank and should be prioritized for underwriting review and early intervention.

---

### 2️⃣ Risk Concentration Over Time
Risk metrics were analyzed using:
- Monthly cohorts
- Exposure-weighted default measures
- Cumulative expected loss

**What this means:**  
Risk does not increase evenly across time. Certain periods show concentrated exposure growth, which may indicate underwriting or policy changes.

---

### 3️⃣ Customer-Level Risk Limitations (Critical Finding)
A large proportion of loans have **missing customer identifiers**.

**Impact:**
- Prevents accurate customer-level risk aggregation
- Limits targeted mitigation actions such as restructuring, pay-downs, or write-offs
- Increases provisioning uncertainty and P&L volatility

**Key takeaway:**  
This is a **data governance issue**, not a modeling issue. Executive decisions made without fixing this could materially misstate risk.

---

## Data Quality Observations
Key data quality issues identified and documented:
- Missing `customer_id` in loan records
- Inconsistent loan status and loan type values
- Transaction-level data not directly aligned with loan delinquency metrics

These checks are explicitly handled in:
- `sql/01_data_quality_checks.sql` — identification of missing customer identifiers, inconsistent loan statuses, and malformed loan product values
- `sql/00_setup_views.sql` — normalization logic applied via views to ensure consistent downstream analysis

---

## How to Run This Analysis

This project uses **DuckDB** and standard SQL.

### DuckDB CLI

```sql
.open bank_loans.duckdb
.read sql/00_setup_views.sql
.read sql/01_data_quality_checks.sql
.read sql/02_product_default_rate.sql
.read sql/03_risk_over_time.sql
.read sql/04_customer_segment_risk.sql

