# Crime Hotspots

A Python-based application to analyze and visualize crime hotspots using data analytics and mapping techniques.<<<<<<< HEAD
# CrimeLens India — Backend Setup Guide

A Flask + pyodbc backend that connects your SQL Server (SSMS) database
to the CrimeLens dashboard frontend.

---

## Folder Structure

```
crimelens_backend/
├── app.py               ← Flask API server (main file)
├── requirements.txt     ← Python packages to install
├── .env.example         ← Copy this to .env and fill in your DB credentials
├── setup_database.sql   ← Run in SSMS to create table + sample data
└── README.md
```

---

## Step-by-Step Setup

### Step 1 — Install Python packages

Open Command Prompt or Terminal in this folder and run:

```bash
pip install -r requirements.txt
```

This installs: Flask, flask-cors, pyodbc, python-dotenv

---

### Step 2 — Install ODBC Driver for SQL Server

pyodbc needs the Microsoft ODBC Driver to talk to SQL Server.

**Windows:**
Download and install from:
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

Choose: ODBC Driver 17 for SQL Server

---

### Step 3 — Configure your database credentials

Copy `.env.example` to `.env`:

```bash
copy .env.example .env       # Windows
cp .env.example .env         # Mac/Linux
```

Then open `.env` and fill in your values:

```
DB_SERVER=localhost\SQLEXPRESS    # or just 'localhost' if using default instance
DB_NAME=CrimeDB                   # your database name in SSMS
DB_USER=sa                        # your SQL Server username
DB_PASSWORD=YourPassword123       # your SQL Server password
```

**Tip:** To find your server name, open SSMS and look at the
"Server name" field in the login dialog — copy it exactly.

---

### Step 4 — Set up your database

**Option A: Your table already exists**

Just update `app.py` to match your column names. Find this section:

```python
cursor.execute("""
    SELECT crime_rate, severity, crime_count
    FROM crimes
    WHERE state = ? AND district = ? AND crime_type = ?
""", state, district, crime_type)
```

Replace `crimes` with your table name, and `crime_rate`, `severity`,
`crime_count` with your actual column names.

**Option B: Create a fresh table**

Open SSMS → New Query → paste the contents of `setup_database.sql` → Execute.
This creates the `CrimeDB` database and `crimes` table with sample data.

---

### Step 5 — Start the Flask server

```bash
python app.py
```

You should see:
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

---

### Step 6 — Connect the frontend

In the dashboard HTML file, find the `compute()` function and replace
the mock `getScore()` call with a real fetch:

```javascript
async function compute() {
    const state      = document.getElementById('state-sel').value;
    const district   = document.getElementById('district-sel').value;
    const crimeType  = selectedCrime;

    if (!state || !district) return;

    const res  = await fetch(`http://127.0.0.1:5000/api/crime?state=${encodeURIComponent(state)}&district=${encodeURIComponent(district)}&type=${encodeURIComponent(crimeType)}`);
    const data = await res.json();

    if (data.error) {
        console.error(data.error);
        return;
    }

    renderScore(data.safety_score, data.severity, data.crime_rate);
    renderRight(data.state, data.district, data.crime_type, data.crime_rate, data.severity, data.comparisons, data.risk_breakdown);
}
```

Also update `onStateChange()` to load districts from the API:

```javascript
async function onStateChange() {
    const state = document.getElementById('state-sel').value;
    const dd    = document.getElementById('district-sel');
    dd.innerHTML = '<option value="">— Loading... —</option>';

    const res  = await fetch(`http://127.0.0.1:5000/api/districts?state=${encodeURIComponent(state)}`);
    const data = await res.json();

    dd.innerHTML = '<option value="">— Select District —</option>';
    data.districts.forEach(d => {
        const o = document.createElement('option');
        o.value = d; o.textContent = d;
        dd.appendChild(o);
    });
    clearResults();
}
```

---

## API Endpoints Reference

| Method | Endpoint | Parameters | Returns |
|--------|----------|------------|---------|
| GET | `/api/states` | — | List of all states |
| GET | `/api/districts` | `state` | List of districts for a state |
| GET | `/api/crime_types` | — | List of all crime types |
| GET | `/api/crime` | `state`, `district`, `type` | Full crime data + safety score |
| GET | `/api/state_summary` | `state` | Crime summary across state |

### Example: `/api/crime` response

```json
{
  "state": "Maharashtra",
  "district": "Pune",
  "crime_type": "Murder",
  "crime_rate": 2.8,
  "severity": "LOW",
  "crime_count": 341,
  "safety_score": 72,
  "comparisons": [
    { "district": "Mumbai", "crime_rate": 4.2, "severity": "MEDIUM", "is_selected": false },
    { "district": "Pune",   "crime_rate": 2.8, "severity": "LOW",    "is_selected": true  }
  ],
  "risk_breakdown": [
    { "crime_type": "Theft",   "crime_rate": 16.8, "severity": "HIGH"   },
    { "crime_type": "Robbery", "crime_rate": 8.7,  "severity": "MEDIUM" },
    { "crime_type": "Murder",  "crime_rate": 2.8,  "severity": "LOW"    }
  ]
}
```

---

## Troubleshooting

**"pyodbc.OperationalError: Data source not found"**
→ Make sure ODBC Driver 17 is installed. Check via: `odbcinst -q -d` (Linux)
  or search "ODBC Data Sources" in Windows Start menu.

**"Login failed for user 'sa'"**
→ Open SSMS → Right-click server → Properties → Security
  → Make sure "SQL Server and Windows Authentication mode" is selected.
  → Also check: right-click the `sa` login → Properties → Status → Login: Enabled

**"Cannot connect to server"**
→ Open SQL Server Configuration Manager
  → SQL Server Network Configuration → Protocols for SQLEXPRESS
  → Enable TCP/IP
  → Restart SQL Server service

**CORS error in browser**
→ Flask-CORS is already configured in app.py. If you deploy to a server,
  update the CORS origin to your frontend domain.

---

## Minimum Required Columns

Your existing table must have AT MINIMUM these columns
(names can differ — just update app.py):

| Column | Type | Example |
|--------|------|---------|
| state | TEXT/NVARCHAR | 'Maharashtra' |
| district | TEXT/NVARCHAR | 'Pune' |
| crime_type | TEXT/NVARCHAR | 'Murder' |
| crime_rate | FLOAT/INT | 2.8 |
| severity | TEXT/NVARCHAR | 'HIGH' / 'MEDIUM' / 'LOW' |

Optional but used: `crime_count` (INT)
=======
# crime-hotspots
A Python-based application to analyze and visualize crime hotspots using data analytics and mapping techniques.
>>>>>>> 309bb98330d23fe11eb7301f15b4dece40c76e92
