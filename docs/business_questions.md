# Business Questions — Project 1: Bank Loan Performance Analysis

## Dataset Context
This project analyzes a simulated banking dataset with five core tables:

- `customers`: customer profile attributes (credit score, employment status, DOB, etc.)
- `accounts`: customer banking relationship (account status, balances)
- `loans`: loan contract details (loan amount, status, payments missed, dates)
- `transactions`: loan-related payments and other cash movements (transaction date, type, amount)
- `defaults`: default event records (days past due, recovery status, exposure at default)

---

# Business Questions & Insights  
**Project: Bank Loan Performance Analysis (SQL + DuckDB)**

This document captures the key business questions addressed in this project and summarizes the quantitative insights derived from SQL-based analysis of a simulated bank loan portfolio.  
The focus is on **default risk**, **exposure concentration**, and **customer-level risk drivers**, with an emphasis on decision-ready outputs.

---

## 1. What is the overall default and delinquency profile of the loan portfolio?

The portfolio exhibits material default and delinquency risk across multiple loan products and customer segments.  
Defaults and early-stage delinquencies are not evenly distributed, indicating the need for segmented risk management rather than uniform credit policies.

**Key observation:**
- Certain loan types and customer cohorts drive disproportionate risk, both in **frequency** (rates) and **financial impact** (exposure).

---

## 2. Which loan products exhibit the highest delinquency risk?

Delinquency analysis by cleaned loan type reveals meaningful variation across products.

**Summary findings:**
- **Personal loans** and **auto loans** show the highest delinquency rates (≈12.8%), indicating elevated short-term repayment stress.
- **Mortgage** and **home equity** products demonstrate lower delinquency rates, consistent with collateralized lending behavior.
- **Business loans** show the lowest delinquency rate, suggesting stronger underwriting or borrower quality.

**Business implication:**  
Unsecured and semi-secured retail products require tighter monitoring, early-warning triggers, and differentiated pricing or underwriting controls.

---

## 3. How does default risk evolve over time?

Cohort-based analysis by origination month shows that default behavior fluctuates meaningfully over time rather than following a smooth trend.

**Key insights:**
- Certain origination cohorts exhibit delinquency rates exceeding **20%**, indicating periods of weaker underwriting or adverse macroeconomic conditions.
- Other cohorts stabilize near zero delinquency, highlighting the importance of vintage-level performance tracking.

**Business implication:**  
Static portfolio averages mask risk. Cohort analysis enables early identification of deteriorating vintages before losses fully materialize.

---

## 4. What data quality issues limit risk visibility?

Several data quality constraints were identified that materially impact customer-level risk aggregation:

**Observed issues:**
- Missing or blank customer identifiers on a subset of loan records
- Inconsistent loan status values requiring normalization
- Misalignment between transaction-level data and loan-level delinquency indicators

**Resolution approach:**
- Standardized loan status values via normalization logic
- Filtered and flagged records with missing customer identifiers
- Built structured views to enable consistent downstream analysis

**Key takeaway:**  
This is a **data governance issue, not a modeling issue**. Without resolving these gaps, portfolio-level risk may be materially misstated.

---

## 5. Which customer segments contribute most to default risk?

Customer-level linkage enabled analysis of default risk by demographic and behavioral segments, combining **loan counts**, **default rates**, and **financial exposure**.

### Risk by Age Band (COUNT + EXPOSURE)

| Age Band | Linked Loans | Defaulted Loans | Default Rate | Total Exposure | Defaulted Exposure |
|--------|-------------|----------------|-------------|---------------|-------------------|
| 45–59 | 124 | 47 | **37.9%** | 13,919,993 | **4,172,852** |
| 30–44 | 137 | 49 | **35.77%** | 15,569,952 | **5,531,144** |
| Under 30 | 73 | 25 | 34.25% | 8,857,028 | 3,474,841 |
| 60+ | 146 | 43 | 29.45% | **16,497,911** | 3,945,948 |

**Key findings:**
- **Ages 45–59** show the **highest default rate** (37.9%), indicating elevated credit stress.
- **Ages 30–44** represent the **largest absolute credit risk**, contributing **$5.53M** in defaulted exposure.
- **Under 30** borrowers exhibit high default rates but lower total exposure due to smaller balances.
- **60+** customers hold the largest total exposure but demonstrate lower relative risk.

**Business implication:**  
Risk mitigation strategies should prioritize **mid-career borrowers (ages 30–59)**, where both default probability and financial impact are highest, while preserving controlled growth in lower-risk senior segments.

---

## 6. How does exposure-weighted risk change the interpretation of defaults?

Default rates alone do not fully capture portfolio risk.

**Key insight:**
- Some segments with slightly lower default rates contribute **significantly higher dollar losses** due to larger loan balances.
- Exposure-weighted analysis shifts focus from “who defaults most often” to “where losses are most material.”

**Business implication:**  
Credit decisions, provisioning, and capital allocation should be driven by **exposure-weighted risk**, not percentages alone.

---

## 7. Executive Summary

- Default risk is concentrated, not evenly distributed.
- Customers aged **30–59** represent the most material source of credit losses.
- Certain loan products and origination cohorts require enhanced monitoring.
- Data quality and customer-level linkage are foundational to accurate risk reporting.
- SQL-only analytics can surface decision-critical insights without advanced modeling.

---

## Author Notes

This analysis intentionally prioritizes **realistic data quality constraints** commonly observed in regulated banking environments.  
Rather than assuming perfect customer identifiers or clean loan statuses, the project demonstrates how governance gaps directly affect risk visibility and executive decision-making.

The objective is not predictive modeling, but **risk transparency** — showing how disciplined SQL analytics can uncover material portfolio risks and limitations that leaders must address.
