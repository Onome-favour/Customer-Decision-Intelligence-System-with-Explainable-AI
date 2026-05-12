# 🧠 Customer Decision Intelligence System with Explainable AI


## 📌 Project Overview

This project delivers an end-to-end **Customer Decision Intelligence System** that transforms raw e-commerce transaction records into actionable customer intelligence. By combining classical RFM behavioural scoring with unsupervised K-Means clustering and interactive Power BI dashboards, the system enables data-driven CRM strategy — with explainability at its core.

The project demonstrates a full data science lifecycle:

```
Raw Transactions → Data Cleaning → RFM Feature Engineering →
K-Means Clustering → Explainable Segment Labels → SQL Aggregation → Power BI Dashboard
```

---

## 🎯 Problem Statement

Retail organisations collect vast transactional data but often lack the analytical infrastructure to convert it into customer-level intelligence. Generic marketing campaigns waste budget on disengaged customers while under-investing in high-value relationships. This system solves that problem by:

- Quantifying each customer's behavioural profile (when, how often, how much they buy)
- Grouping customers into interpretable, actionable segments using both rule-based and ML-driven approaches
- Surfacing findings through an interactive business dashboard that non-technical stakeholders can use

---

## 🗂️ Repository Structure

```
├── customer_transactions_cleaned.ipynb   # Main analysis notebook
├── data/
│   ├── Online Retail Data Set.csv        # Raw source data (UCI)
│   ├── cleaned_transactions.csv          # After data cleaning
│   ├── customer_rfm.csv                  # RFM scores + rule-based segments
│   └── customer_rfm_final.csv            # + K-Means cluster labels
├── powerbi/
│   └── customer_intelligence.pbix        # Power BI dashboard file
└── README.md
```

---

## 🛠️ Technologies Used

| Layer | Tools |
|-------|-------|
| **Data Processing** | Python 3, pandas, datetime |
| **Machine Learning** | scikit-learn (KMeans, StandardScaler) |
| **Feature Engineering** | RFM (Recency / Frequency / Monetary) |
| **Data Storage** | CSV, SQL-compatible exports |
| **Visualisation** | Microsoft Power BI Desktop |
| **Environment** | Jupyter Notebook |

---

## 📦 Dataset

**Source:** https://www.kaggle.com/datasets/ishanshrivastava28/tata-online-retail-dataset?resource=download)

**Key fields:** `InvoiceNo`, `StockCode`, `Description`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`

---

## 🧹 Data Cleaning Process

```python
# 1. Load with correct encoding
df = pd.read_csv('Online Retail Data Set.csv', encoding='ISO-8859-1')

# 2. Remove rows with no CustomerID (cannot be attributed)
df.dropna(subset=['CustomerID'], inplace=True)

# 3. Parse dates
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

# 4. Remove returns and cancellations (Quantity <= 0)
df = df[df['Quantity'] > 0]

# 5. Derive total transaction value
df['TotalPrice'] = df['Quantity'] * df['UnitPrice']

# 6. Remove duplicate rows
df.drop_duplicates(inplace=True)
```

**Result:** A clean dataset ready for customer-level aggregation.

---

## 📊 RFM Analysis

RFM is a proven behavioural segmentation framework:

| Dimension | Definition | Measurement |
|-----------|-----------|-------------|
| **Recency (R)** | How recently did the customer buy? | Days since last purchase |
| **Frequency (F)** | How often do they buy? | Distinct invoice count |
| **Monetary (M)** | How much do they spend? | Sum of TotalPrice |

Each dimension is scored 1–4 using quartile binning (`pd.qcut`), producing a composite 3-digit RFM score per customer. Rule-based segment logic is then applied:

```python
def segment_customer(row):
    if row['RFM_Score'] == '444':
        return 'Best Customers'      # Top recency + frequency + monetary
    elif row['F_score'] == 4:
        return 'Loyal Customers'     # High frequency
    elif row['R_score'] == 4:
        return 'Recent Customers'    # Bought recently
    else:
        return 'At Risk'             # Low engagement across dimensions
```

---

## 🤖 K-Means Clustering

Unsupervised clustering provides a data-driven cross-check on the rule-based segments and reveals sub-groups that scoring rules may miss.

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# Feature matrix
X = rfm[['Recency', 'Frequency', 'Monetary']]

# Standardise (critical — prevents monetary scale dominating distance)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Fit K-Means with k=4
kmeans = KMeans(n_clusters=4, random_state=42)
rfm['Cluster'] = kmeans.fit_predict(X_scaled)
```

**Cluster labels** (assigned by inspecting centroid means):

| Cluster | Label | Profile |
|---------|-------|---------|
| 0 | Loyal Customers | Moderate recency, high frequency, moderate spend |
| 1 | At Risk Customers | High recency (days since purchase), low frequency |
| 2 | VIP Customers | Very recent, very frequent, highest monetary value |
| 3 | Occasional Customers | Moderate across all dimensions |

> ⚠️ **Note on explainability:** Cluster labels are derived from centroid inspection — each label reflects the dominant RFM pattern within that cluster, providing a transparent business narrative alongside the ML assignment.

---

## 🗄️ SQL Integration

The cleaned and labelled CSV outputs are structured for SQL querying. Example aggregation:

```sql
-- Revenue and customer count by segment
SELECT
    segment,
    COUNT(DISTINCT CustomerID)          AS customer_count,
    SUM(monetary)                        AS total_revenue,
    AVG(monetary)                        AS avg_customer_value,
    AVG(recency)                         AS avg_days_since_purchase
FROM customer_rfm_final
GROUP BY segment
ORDER BY total_revenue DESC;
```

This query directly feeds the KPI cards and segment comparison charts in the Power BI dashboard.

---

## 📈 Power BI Dashboard

The dashboard provides five interactive visuals with a segment slicer for drill-down:

| Visual | Purpose |
|--------|---------|
| **KPI Cards** | Total customers, total revenue, average customer value |
| **Revenue by Segment** (bar) | Compare segment revenue contribution at a glance |
| **Segment Distribution** (pie) | Show proportional size of each customer group |
| **Avg Spending per ML Cluster** (bar) | Cross-validate K-Means clusters against monetary value |
| **Avg Frequency by Cluster** (line) | Show purchase cadence differences across clusters |

**Segment slicer** enables executives to isolate any single segment and examine its complete profile independently.

---

## 📋 Key Results & Insights

| Segment | Customers | Revenue | Avg Value | Revenue Share |
|---------|-----------|---------|-----------|---------------|
| Best Customers | 488 (11.2%) | £4.42M | £9,060 | **49.7%** |
| At Risk | 2,736 (63.1%) | £1.99M | £726 | 22.4% |
| Loyal Customers | 597 (13.8%) | £1.82M | £3,050 | 20.5% |
| Recent Customers | 518 (11.9%) | £660K | £1,270 | 7.4% |

**Top 3 business insights:**

1. **The 80/20 principle holds strongly:** the top 11% of customers generate ~50% of revenue, making high-value customer retention the single highest-ROI investment.
2. **The At Risk segment is the largest reactivation opportunity:** 2,736 customers with an average value of £726 represent ~£2M in recoverable revenue if reactivated to Loyal status.
3. **K-Means clusters confirm RFM intuition but add granularity:** VIP cluster customers (Cluster 2) show average purchase frequency ~70× higher than the lowest cluster, validating the segmentation boundary.

---

## 🔮 Future Improvements

- [ ] **SHAP integration** — per-customer feature attribution to explain individual segment assignments
- [ ] **Churn prediction** — supervised classifier (XGBoost/LightGBM) trained on labelled segments
- [ ] **Customer Lifetime Value (CLV)** modelling with cohort retention analysis
- [ ] **Optimal k selection** — Elbow method + Silhouette score visualisation
- [ ] **Real-time pipeline** — Kafka + Spark streaming for live segment updates
- [ ] **NLP product enrichment** — topic modelling on product descriptions to add category-level signals

---



---

## 🙏 Acknowledgements

Dataset sourced from Kaggle: [TATA: Online Retail Dataset](https://www.kaggle.com/datasets/ishanshrivastava28/tata-online-retail-dataset)
uploaded by Ishan Shrivastava. Originally derived from the UCI Online Retail Dataset.
