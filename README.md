# IT Helpdesk Process Efficiency Dashboard
## Bottleneck Analysis & Operational Optimization

**Author:** Usman Ghani Khan  
**Tools:** SQL (PostgreSQL), Tableau, Python  
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

**Source:** Simulated IT helpdesk dataset based on the [Mendeley Helpdesk Dataset](https://data.mendeley.com/datasets/39bp3vv62t/1)  
**Description:** Enhanced event log data modeling a typical IT service desk workflow  
**Volume:** 500 tickets, 4,500 events  
**Process Stages:** 9 activities from ticket creation to closure  

**Dataset Fields:**
- Case_ID (ticket identifier)
- Activity (process stage: Ticket Created, Initial Triage, Assigned to Agent, etc.)
- Timestamp (event time)
- Priority (Critical, High, Medium, Low)
- Category (Hardware, Software, Network, Email, Access)
- Agent (assigned support agent)

**Why simulated enhancement?**
The original Mendeley dataset contains only Case_ID, Activity, and Timestamp. To demonstrate comprehensive BI analysis capabilities, this project uses a simulated enhancement that adds:
- **Priority levels** (for SLA and urgency analysis)
- **Category types** (for ticket segmentation)
- **Agent assignments** (for workload analysis)

This enhancement allows demonstration of realistic business scenarios including priority-based segmentation, category performance analysis, and resource allocation optimization—skills directly applicable to real BI work.

---

## 🔍 Methodology

### 1. Database Setup & Data Loading
- Created PostgreSQL database schema for event log structure
- Loaded helpdesk ticket data (500 tickets, 4,500 events)
- Validated data quality: timestamps, case IDs, activity names

### 2. SQL-Based Analysis (Primary Tool)

**All core analysis performed using PostgreSQL queries with advanced SQL techniques:**

**Cycle Time Calculation (Query 1)**
```sql
-- Used LEAD() window function to calculate time between events
LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp)
-- Extracted hours using EPOCH conversion
EXTRACT(EPOCH FROM (end_time - start_time)) / 3600
```

**Bottleneck Identification (Query 2)**
```sql
-- Flagged severity levels using CASE statements
CASE 
    WHEN AVG(duration_hours) > 40 THEN 'CRITICAL'
    WHEN AVG(duration_hours) > 20 THEN 'HIGH'
    ELSE 'MODERATE'
END AS severity_level
```

**Priority Segmentation (Query 3)**
- Grouped bottleneck stages by priority level
- Compared wait times: Critical vs High vs Medium vs Low
- Identified whether SLAs are being met

**Category Analysis (Query 4)**
- Calculated end-to-end resolution time using MIN/MAX timestamps
- Cross-tabulated category × priority for comprehensive view
- Used PERCENTILE_CONT for median calculations

**Agent Performance (Query 5)**
- Analyzed workload distribution across support team
- Calculated handling time efficiency per agent
- Filtered for agents with ≥10 tickets (significant volume)

**Business Impact Modeling (Query 7)**
- Calculated total bottleneck hours per ticket
- Modeled 30% reduction scenario
- Computed FTE equivalency: (annual_hours_saved / 2080)
- Estimated cost savings at $30/hour loaded cost

### 3. Data Export
- Used Python (Pandas + SQLAlchemy) solely for exporting SQL results to CSV
- Exported 2 files: `stage_summary.csv`, `resolution_summary.csv`

### 4. Tableau Dashboard
- Imported CSV files into Tableau
- Created 3-panel dashboard with bottleneck ranking, category distribution, priority impact
- Added executive summary with key metrics


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

**7 comprehensive queries covering all analysis:**

1. **Cycle Time Calculation** - LEAD() window functions, PARTITION BY case_id
2. **Bottleneck Identification** - Aggregations, CASE severity flags, HAVING filters
3. **Priority Segmentation** - GROUP BY priority, focused on top 2 bottlenecks
4. **Category Analysis** - MIN/MAX timestamps, cross-tabulation
5. **Agent Performance** - Workload distribution, efficiency metrics
6. **Customer Interaction Impact** - Isolation of customer-dependent delays
7. **Business Impact Modeling** - FTE calculation, cost savings projection

**Advanced SQL techniques demonstrated:**
- Window functions (LEAD, LAG, PARTITION BY)
- Common Table Expressions (WITH clauses)
- Statistical functions (PERCENTILE_CONT, STDDEV)
- CASE statements for conditional logic
- HAVING clauses for aggregate filtering
- EPOCH time extraction and conversion

### Python Script (`/analysis/export_results.py`)

- **Purpose:** Export SQL query results to CSV for Tableau
- **Tools:** Pandas (CSV I/O), SQLAlchemy (database connection)

### Tableau Dashboard (`/dashboards/`)
- **Panel 1:** Average cycle time by process stage (horizontal bar chart, severity colors)
- **Panel 2:** Resolution time distribution by category (box-and-whisker plot)
- **Panel 3:** Average resolution time by priority (grouped bar chart)
- **Text Box:** Key findings and business impact metrics

---

## 📂 Repository Structure

```
helpdesk-process-analysis/
├── README.md                      # This file
├── data/
│   ├── dataset_source.md          # Link to Mendeley dataset
│   └── helpdesk_process_log.csv   # Simulated helpdesk dataset
├── sql/
│   └── analysis_queries.sql       # PostgreSQL queries (ALL analysis logic)
├── analysis/
│   └── export_results.py          # Minimal Python script for CSV export
├── dashboards/
│   └── helpdesk_dashboard.png     # Tableau dashboard screenshot
└── results/
    ├── stage_summary.csv          # SQL query output: cycle time statistics
    ├── resolution_summary.csv     # SQL query output: resolution times
    └── recommendations.csv        # SQL query output: improvement actions
```

---

## 🎓 Skills Demonstrated

✅ **SQL (PostgreSQL):** Window functions (LEAD, PARTITION BY), CTEs, aggregations, CASE statements, statistical functions (PERCENTILE_CONT, STDDEV), time-based calculations  
✅ **Process Mining:** Event log analysis, cycle time calculation, bottleneck identification, workflow optimization  
✅ **Data Visualization:** Tableau dashboard design, effective visual storytelling, executive reporting  
✅ **Business Analysis:** Translating data insights into actionable recommendations, stakeholder communication  
✅ **Cost-Benefit Analysis:** ROI calculation, FTE equivalency modeling, business case development  
✅ **Python:** Basic Pandas for data export, SQLAlchemy for database connectivity  

---

## 🚀 How to Reproduce
1. **Use dataset** from `/data/helpdesk_process_log.csv`
2. **Load into PostgreSQL:**
   ```sql
   CREATE TABLE helpdesk_events (
       Case_ID VARCHAR(50),
       Activity VARCHAR(100),
       Timestamp TIMESTAMP,
       Priority VARCHAR(20),
       Category VARCHAR(50),
       Agent VARCHAR(50)
   );
   ```
3. **Run SQL queries** from `/sql/analysis_queries.sql`
4. **Execute Python export file:**
   ```bash
   python analysis/export_results.py
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
