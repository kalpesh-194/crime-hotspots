from flask import Flask, request, jsonify, render_template
import pyodbc
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


# ---------------- DB CONNECTION ----------------
def get_db_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=LAPTOP-L5A5DAUK\\SQLEXPRESS;"   # 👈 THEIR server
        "DATABASE=crime_db;"
        "Trusted_Connection=yes;"
    )

# ---------------- HOME PAGE ----------------
@app.route("/")
def home():
    return render_template("index.html")


# ---------------- STATES ----------------
@app.route("/api/states")
def states():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT DISTINCT state FROM crimes ORDER BY state")

    data = [row[0] for row in cursor.fetchall()]

    conn.close()
    return jsonify(data)


# ---------------- DISTRICTS ----------------
@app.route("/api/districts")
def districts():
    state = request.args.get("state")

    conn = get_db_connection()
    cursor = conn.cursor()

    # ✅ case-insensitive match
    cursor.execute(
        "SELECT DISTINCT district FROM crimes WHERE LOWER(state)=LOWER(?) ORDER BY district",
        state
    )

    data = [row[0] for row in cursor.fetchall()]

    conn.close()
    return jsonify(data)


# ---------------- CRIME DATA ----------------
@app.route("/api/crime")
def crime():
    state = request.args.get("state")
    district = request.args.get("district")
    crime_type = request.args.get("type")

    conn = get_db_connection()
    cursor = conn.cursor()

    # ✅ FULLY case-insensitive query
    cursor.execute(
        """
        SELECT cases, severity 
        FROM crimes 
        WHERE LOWER(state)=LOWER(?) 
        AND LOWER(district)=LOWER(?) 
        AND LOWER(crime_type)=LOWER(?)
        """,
        state, district, crime_type
    )

    row = cursor.fetchone()
    conn.close()

    if not row:
        return jsonify({"error": "No data"}), 404

    cases, severity = row

    # ✅ compute values (since DB doesn't have these columns)
    crime_rate = min(100, max(5, cases // 2))
    safety_score = 100 - crime_rate

    return jsonify({
        "crime_count": cases,
        "severity": severity,
        "crime_rate": crime_rate,
        "safety_score": safety_score
    })


# ---------------- RUN APP ----------------
if __name__ == "__main__":
    app.run(debug=True, port=5000)