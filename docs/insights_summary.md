# Executive Insights Summary — Bank Loan Performance Analysis

## Portfolio Snapshot
- Loan product definitions required normalization due to inconsistent formatting (e.g., case differences).
- Loan status values also required standardization (e.g., “charged off” vs “charge-off”).
- A material data quality issue exists: many loan records contain missing customer identifiers, limiting customer-level drilldowns.

---

## Key Findings

### 1) Highest Default Risk Products
- **Home Equity** loans show the highest default risk across both:
  - Default rate by loan count
  - Exposure-weighted default rate (money-based)

**Why it matters:**  
Home Equity loans represent the strongest concentration of loss risk and should be prioritized for underwriting review and early intervention strategies.

---

### 2) Default Risk Over Time
- Default risk varies across origination cohorts (monthly).
- Cohort trend analysis helps identify periods where underwriting or risk appetite may have weakened, or where macro conditions increased borrower stress.

**Why it matters:**  
Rising cohort risk can signal policy or market-driven deterioration and supports proactive provisioning and tighter underwriting.

---

### 3) Customer Segments Driving Risk (with disclosure)
- Customer-level segmentation is constrained because **many loans have missing customer IDs**.
- To partially enable segmentation, loans were linked to customers using a **transaction-derived bridge** (loan payment transactions).
- Segment results are reported alongside linkage coverage to prevent misleading conclusions.

**Why it matters:**  
With complete customer linkage, the bank could better target mitigation actions (restructuring, pay-down initiatives, write-offs) to reduce provisioning shocks and protect profitability.

---

## Data Quality & Governance Observations (High Priority)
### Missing Customer Identifiers in Loans
- Missing loan-to-customer linkage prevents customer-level exposure monitoring.
- In a real banking environment, this would represent a governance and control concern because credit exposure cannot be reliably attributed to customers.

### Inconsistent Category Values
- Inconsistent loan type and loan status values can materially distort risk metrics if not standardized.

**Recommendation:**  
Implement upstream validation rules (non-null keys where required), enforce referential integrity, and standardize categorical fields during ETL to ensure reliable analytics and risk reporting.

---

## Recommended Actions (Business-Focused)
1. **Prioritize Home Equity risk controls:** tighten underwriting, monitor early-warning signals, and review pricing.
2. **Adopt cohort monitoring:** track monthly origination risk to detect deterioration early.
3. **Fix customer linkage integrity:** enables targeted mitigation at customer level and improves provisioning accuracy.
4. **Standardize data definitions:** improve trust in executive dashboards and risk reports.
