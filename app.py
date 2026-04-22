from flask import Flask, request, jsonify, render_template
import pyodbc
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# ✅ SQL CONNECTION (YOUR SERVER)
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=LAPTOP-L5A5DAUK\\SQLEXPRESS;"
    "DATABASE=crime_db;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()


# ---------------- HOME PAGE ----------------
@app.route("/")
def home():
    return render_template("index.html")


# ---------------- STATES ----------------
@app.route("/api/states")
def states():
    cursor.execute("SELECT DISTINCT state FROM crimes ORDER BY state")
    return jsonify([row[0] for row in cursor.fetchall()])


# ---------------- DISTRICTS ----------------
@app.route("/api/districts")
def districts():
    state = request.args.get("state")
    cursor.execute(
        "SELECT DISTINCT district FROM crimes WHERE state=? ORDER BY district",
        state
    )
    return jsonify([row[0] for row in cursor.fetchall()])


# ---------------- CRIME DATA ----------------
@app.route("/api/crime")
def crime():
    state = request.args.get("state")
    district = request.args.get("district")
    crime_type = request.args.get("type")

    cursor.execute(
        "SELECT cases, severity FROM crimes WHERE state=? AND district=? AND crime_type=?",
        state, district, crime_type
    )

    row = cursor.fetchone()

    if not row:
        return jsonify({"error": "No data"}), 404

    cases, severity = row

    crime_rate = min(100, max(5, cases // 2))
    safety_score = 100 - crime_rate

    return jsonify({
        "crime_count": cases,
        "severity": severity,
        "crime_rate": crime_rate,
        "safety_score": safety_score
    })


if __name__ == "__main__":
    app.run(debug=True)