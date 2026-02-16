# Dataset Information

**Type:** Simulated IT Helpdesk Process Log (Enhanced from Mendeley Dataset)

**Base Dataset:** [Mendeley Helpdesk Dataset](https://data.mendeley.com/datasets/39bp3vv62t/1)
- Original: 3,804 tickets, 13,710 events
- Fields: Case_ID, Activity, Timestamp
- License: MIT

**Enhancement Rationale:**
The original Mendeley dataset is excellent for basic process mining but lacks fields needed for comprehensive BI analysis. This project uses a simulated enhancement that adds:
- **Priority levels** (Critical, High, Medium, Low) for SLA analysis
- **Category types** (Hardware, Software, Network, Email, Access) for segmentation
- **Agent assignments** for workload distribution analysis

**Simulation Approach:**
- Maintained the 9-stage process structure from Mendeley dataset
- Reduced volume to 500 tickets for focused analysis
- Applied realistic distributions for priority, category, and agent fields
- Modeled actual IT support bottleneck patterns (customer response delays, verification waits)

**Why Enhanced Data:**
This approach demonstrates:
1. **Data modeling skills** - schema design for analytical needs
2. **Business understanding** - knowing what fields drive BI insights
3. **SQL proficiency** - ability to work with comprehensive relational data
4. **Realistic analysis** - patterns mirror actual service desk challenges

All SQL queries and analytical techniques apply directly to real-world helpdesk data with these common fields.
