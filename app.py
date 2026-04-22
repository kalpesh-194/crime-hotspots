from flask import Flask, jsonify, request
from flask_cors import CORS
import pyodbc
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)  # Allow requests from your frontend

# ─────────────────────────────────────────
#  SQL SERVER CONNECTION
#  Edit .env file with your actual credentials
# ─────────────────────────────────────────
def get_connection():
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={os.getenv('DB_SERVER', 'localhost')};"
        f"DATABASE={os.getenv('DB_NAME', 'CrimeDB')};"
        f"UID={os.getenv('DB_USER', 'sa')};"
        f"PWD={os.getenv('DB_PASSWORD', 'your_password')};"
        f"TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)


# ─────────────────────────────────────────
#  ROUTE 1: Get all states
#  GET /api/states
# ─────────────────────────────────────────
@app.route('/api/states', methods=['GET'])
def get_states():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DISTINCT state FROM crimes ORDER BY state")
        states = [row[0] for row in cursor.fetchall()]
        conn.close()
        return jsonify({"states": states})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ─────────────────────────────────────────
#  ROUTE 2: Get districts for a state
#  GET /api/districts?state=Maharashtra
# ─────────────────────────────────────────
@app.route('/api/districts', methods=['GET'])
def get_districts():
    state = request.args.get('state')
    if not state:
        return jsonify({"error": "state parameter required"}), 400
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT DISTINCT district FROM crimes WHERE state = ? ORDER BY district",
            state
        )
        districts = [row[0] for row in cursor.fetchall()]
        conn.close()
        return jsonify({"districts": districts})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ─────────────────────────────────────────
#  ROUTE 3: Get crime types
#  GET /api/crime_types
# ─────────────────────────────────────────
@app.route('/api/crime_types', methods=['GET'])
def get_crime_types():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DISTINCT crime_type FROM crimes ORDER BY crime_type")
        types = [row[0] for row in cursor.fetchall()]
        conn.close()
        return jsonify({"crime_types": types})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ─────────────────────────────────────────
#  ROUTE 4: Main crime data for a location
#  GET /api/crime?state=Maharashtra&district=Pune&type=Murder
# ─────────────────────────────────────────
@app.route('/api/crime', methods=['GET'])
def get_crime():
    state       = request.args.get('state')
    district    = request.args.get('district')
    crime_type  = request.args.get('type')

    if not all([state, district, crime_type]):
        return jsonify({"error": "state, district, and type are required"}), 400

    try:
        conn   = get_connection()
        cursor = conn.cursor()

        # ── Main record for the selected district ──
        cursor.execute("""
            SELECT
                crime_rate,
                severity,
                crime_count
            FROM crimes
            WHERE state       = ?
              AND district    = ?
              AND crime_type  = ?
        """, state, district, crime_type)

        row = cursor.fetchone()
        if not row:
            conn.close()
            return jsonify({"error": "No data found for this combination"}), 404

        crime_rate, severity, crime_count = row

        # ── Safety score: inverse of normalised rate ──
        # Normalise rate against state max so score is relative to state
        cursor.execute("""
            SELECT MAX(crime_rate)
            FROM crimes
            WHERE state = ? AND crime_type = ?
        """, state, crime_type)
        max_row = cursor.fetchone()
        state_max = max_row[0] if max_row and max_row[0] else crime_rate or 1

        safety_score = round(100 - (crime_rate / state_max) * 100) if state_max else 50

        # ── District comparison (all districts in the same state) ──
        cursor.execute("""
            SELECT
                district,
                crime_rate,
                severity
            FROM crimes
            WHERE state      = ?
              AND crime_type = ?
            ORDER BY crime_rate DESC
        """, state, crime_type)

        comparisons = [
            {
                "district": r[0],
                "crime_rate": r[1],
                "severity": r[2],
                "is_selected": r[0] == district
            }
            for r in cursor.fetchall()
        ]

        # ── Risk breakdown: all crime types for this district ──
        cursor.execute("""
            SELECT
                crime_type,
                crime_rate,
                severity
            FROM crimes
            WHERE state    = ?
              AND district = ?
            ORDER BY crime_rate DESC
        """, state, district)

        risk_breakdown = [
            {
                "crime_type": r[0],
                "crime_rate": r[1],
                "severity":   r[2]
            }
            for r in cursor.fetchall()
        ]

        conn.close()

        return jsonify({
            "state":          state,
            "district":       district,
            "crime_type":     crime_type,
            "crime_rate":     crime_rate,
            "severity":       severity,       # HIGH / MEDIUM / LOW
            "crime_count":    crime_count,
            "safety_score":   safety_score,
            "comparisons":    comparisons,
            "risk_breakdown": risk_breakdown
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ─────────────────────────────────────────
#  ROUTE 5: State-level summary
#  GET /api/state_summary?state=Maharashtra
# ─────────────────────────────────────────
@app.route('/api/state_summary', methods=['GET'])
def state_summary():
    state = request.args.get('state')
    if not state:
        return jsonify({"error": "state parameter required"}), 400
    try:
        conn   = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                crime_type,
                AVG(crime_rate)  AS avg_rate,
                MAX(crime_rate)  AS max_rate,
                COUNT(DISTINCT district) AS district_count
            FROM crimes
            WHERE state = ?
            GROUP BY crime_type
            ORDER BY avg_rate DESC
        """, state)
        rows = cursor.fetchall()
        conn.close()
        summary = [
            {
                "crime_type":      r[0],
                "avg_rate":        round(r[1], 2),
                "max_rate":        r[2],
                "district_count":  r[3]
            }
            for r in rows
        ]
        return jsonify({"state": state, "summary": summary})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ─────────────────────────────────────────
if __name__ == '__main__':
    app.run(debug=True, port=5000)
