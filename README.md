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
