# IT Helpdesk Process Efficiency Dashboard
## Bottleneck Analysis & Operational Optimization

**Author:** Usman Ghani Khan  
**Tools:** SQL (PostgreSQL), Python (Pandas, NumPy), Tableau, Advanced Excel  
**Domain:** IT Operations, Process Improvement  

---

## 📊 Business Problem

IT helpdesk operations face a critical challenge: **long ticket resolution times** that impact customer satisfaction and operational costs. Without clear visibility into process bottlenecks, teams struggle to identify where delays occur and how to optimize workflows.

**Key Questions:**
- Which process stages consume the most time?
- Are specific ticket categories or priorities driving delays?
- What is the financial impact of process inefficiencies?
- Which improvements would yield the highest ROI?

---

## 🎯 Project Objectives

1. **Identify bottlenecks** in the IT helpdesk process using event log analysis
2. **Quantify impact** by calculating cycle times and total resolution durations
3. **Segment performance** by priority level and ticket category
4. **Recommend improvements** with projected cost savings and efficiency gains

---

## 📁 Dataset

**Source:** [Mendeley Data - Helpdesk Dataset](https://data.mendeley.com/datasets/39bp3vv62t/1)  
**Description:** Real ticketing management process from an Italian software company's help desk  
**License:** MIT License  
**Volume:** 3,804 process instances (tickets), 13,710 events  
**Process Stages:** 9 activities from ticket creation to closure  

**Why this dataset?**
- Real-world business process data (not synthetic/tutorial data)
- Contains timestamp-level granularity for accurate cycle time analysis
- Demonstrates process mining and operational analytics skills
- Publicly available and verifiable

---

## 🔍 Methodology

### 1. Data Preparation
- Loaded event log data into PostgreSQL database
- Wrote SQL queries to calculate time deltas between consecutive process stages
- Cleaned data: handled null timestamps, standardized activity names

### 2. Bottleneck Identification
- Calculated average, median, and standard deviation of cycle times for each stage
- Flagged stages with >20 hour average wait time as bottlenecks
- Categorized severity: CRITICAL (>40h), HIGH (20-40h), MODERATE (<20h)

### 3. Segmentation Analysis
- Grouped tickets by **Priority** (Critical, High, Medium, Low)
- Grouped tickets by **Category** (Hardware, Software, Network, Email, Access)
- Analyzed how priority and category affect resolution time

### 4. Business Impact Calculation
- Identified top 2 bottlenecks consuming 73% of total resolution time
- Calculated potential savings from 30% reduction in bottleneck time
- Estimated FTE equivalency and annual cost savings

### 5. Recommendation Engine
- Generated data-driven recommendations based on bottleneck patterns
- Prioritized actions by expected impact and implementation feasibility

---

## 📈 Key Findings

### Critical Bottlenecks Identified

| Process Stage | Avg Wait Time | Median | Impact |
|--------------|---------------|---------|--------|
| **Investigation → Customer Response** | 44.3 hours | 39.8 hours | CRITICAL |
| **Solution Implemented → Verification** | 43.6 hours | 44.2 hours | CRITICAL |
| Solution Proposed → Implementation | 8.8 hours | 8.8 hours | MODERATE |

**Combined bottleneck time: 87.9 hours per ticket (73% of total resolution time)**

### Performance by Priority

- **Critical tickets**: 59.9 hours average wait during investigation stage
- **High tickets**: 41.5 hours  
- **Medium tickets**: 46.6 hours  
- **Low tickets**: 39.6 hours  

**Insight:** Critical tickets are **not being prioritized effectively** — they experience the longest delays.

### Resolution Time by Category

| Category | Avg Resolution Time |
|----------|---------------------|
| Hardware | 112.2 hours (4.7 days) |
| Software | 110.6 hours (4.6 days) |
| Network | 110.2 hours (4.6 days) |

All categories show similar resolution times, suggesting bottlenecks are **process-driven, not category-specific**.

---

## 💡 Recommendations & Business Impact

### Recommended Actions (Projected 30% Bottleneck Reduction)

| # | Action | Target Bottleneck | Expected Impact |
|---|--------|-------------------|-----------------|
| 1 | **Automated customer reminder system** for tickets waiting >48 hours | Customer Response | 20-30% reduction in wait time |
| 2 | **Self-service verification portal** with auto-close after 72 hours | Customer Verification | 25% reduction in verification time |
| 3 | **Dedicated resources** for critical/high priority tickets (<4 hour SLA) | Priority Handling | 40% improvement in critical ticket resolution |
| 4 | **Searchable knowledge base** with solution templates | Investigation | 15-20% reduction in investigation time |

### Estimated Business Value

- **Time saved per ticket:** 26.4 hours (30% of 87.9-hour bottleneck time)
- **Annual hours saved:** 13,194 hours (based on 500 tickets/year)
- **FTE equivalency:** 6.3 full-time employees
- **Annual cost savings:** $395,820 (assuming $30/hour loaded cost)

---

## 🛠️ Technical Implementation

### SQL Queries (`/sql/analysis_queries.sql`)
- Cycle time calculation using window functions (LEAD, LAG)
- Bottleneck identification with aggregations and CASE statements
- Agent performance analysis
- Customer interaction tracking

### Python Analysis (`/analysis/bottleneck_analysis.py`)
- Event log processing with Pandas
- Statistical aggregations (mean, median, percentiles)
- Business impact calculations
- Automated recommendation generation

### Tableau Dashboard (`/dashboards/`)
- **Panel 1:** Average cycle time by process stage (bar chart with severity coloring)
- **Panel 2:** Resolution time distribution by category (box plot)
- **Panel 3:** Average resolution time by priority (grouped bar chart)
- **Panel 4:** Key metrics summary and recommended actions

---

## 📂 Repository Structure

```
helpdesk-process-analysis/
├── README.md                       # This file
├── data/
│   └── dataset_source.md           # Link to Mendeley dataset
├── sql/
│   └── analysis_queries.sql        # PostgreSQL queries for data extraction
├── analysis/
│   └── bottleneck_analysis.py      # Python script for statistical analysis
├── dashboards/
│   └── helpdesk_dashboard.png      # Tableau dashboard screenshot
└── results/
    ├── stage_summary.csv           # Aggregated cycle time statistics
    ├── resolution_summary.csv      # Resolution time by category/priority
    └── recommendations.csv         # Generated improvement recommendations
```

---

## 🎓 Skills Demonstrated

✅ **Process Mining:** Event log analysis, cycle time calculation, bottleneck identification  
✅ **SQL:** Window functions, aggregations, complex joins, time-based queries  
✅ **Python:** Pandas for data manipulation, statistical analysis, automation  
✅ **Data Visualization:** Tableau dashboard design, effective visual storytelling  
✅ **Business Analysis:** Translating data insights into actionable recommendations  
✅ **Cost-Benefit Analysis:** Quantifying ROI and business impact  

---

## 🚀 How to Reproduce

1. **Download dataset** from [Mendeley repository](https://data.mendeley.com/datasets/39bp3vv62t/1)
2. **Load into PostgreSQL:**
   ```sql
   CREATE TABLE helpdesk_events (
       case_id VARCHAR(50),
       activity VARCHAR(100),
       timestamp TIMESTAMP,
       priority VARCHAR(20),
       category VARCHAR(50),
       agent VARCHAR(50)
   );
   ```
3. **Run SQL queries** from `/sql/analysis_queries.sql`
4. **Execute Python analysis:**
   ```bash
   python analysis/bottleneck_analysis.py
   ```
5. **Import results CSVs into Tableau** to recreate dashboard

---

## 📞 Contact

**Usman Ghani Khan**
💼 [LinkedIn](https://linkedin.com/in/usman-ghani-k)  
🔗 [GitHub](https://github.com/usman-ghani-khan)

---

## 📄 License

This analysis uses the Mendeley Helpdesk dataset, which is licensed under MIT License.  
Analysis code and documentation are original work by Usman Ghani Khan.
