let selectedCrimeType = "Murder";

// ---------------- LOADING EFFECT ----------------
function showLoading() {
    document.getElementById("right-panel").innerHTML = `
        <div class="panel-card">
            <div class="placeholder">
                <div class="ph-icon">⚡</div>
                <div class="ph-text">Loading data...</div>
            </div>
        </div>
    `;
}

// ---------------- ERROR UI ----------------
function showError(msg) {
    document.getElementById("right-panel").innerHTML = `
        <div class="panel-card">
            <div class="placeholder">
                <div class="ph-icon">❌</div>
                <div class="ph-text">${msg}</div>
            </div>
        </div>
    `;
}

// ---------------- LOAD STATES ----------------
window.onload = function () {
    fetchStates();
};

function fetchStates() {
    fetch("/api/states")
        .then(res => res.json())
        .then(data => {
            const stateSel = document.getElementById("state-sel");

            stateSel.innerHTML = '<option value="">— Select State —</option>';

            data.forEach(state => {
                let opt = document.createElement("option");
                opt.value = state;
                opt.textContent = state;
                stateSel.appendChild(opt);
            });
        })
        .catch(err => console.error("State load error:", err));
}

// ---------------- LOAD DISTRICTS ----------------
async function onStateChange() {
    const state = document.getElementById("state-sel").value;
    if (!state) return;

    showLoading();

    try {
        const res = await fetch(`/api/districts?state=${state}`);
        const data = await res.json();

        const districtBox = document.getElementById("district-sel");
        districtBox.innerHTML = `<option value="">— Select District —</option>`;

        // ✅ FIXED HERE (important)
        data.forEach(d => {
            districtBox.innerHTML += `<option value="${d}">${d}</option>`;
        });

    } catch {
        showError("Failed to load districts");
    }
}

// ---------------- SELECT CRIME ----------------
function selectCrime(el) {
    document.querySelectorAll(".cpill").forEach(c => c.classList.remove("active"));
    el.classList.add("active");

    selectedCrimeType = el.getAttribute("data-crime");

    compute();
}

// ---------------- MAIN COMPUTE ----------------
async function compute() {
    const state = document.getElementById("state-sel").value;
    const district = document.getElementById("district-sel").value;

    if (!state || !district) return;

    showLoading();

    try {
        const res = await fetch(`/api/crime?state=${state}&district=${district}&type=${selectedCrimeType}`);
        const data = await res.json();

        if (data.error) {
            showError(data.error);
            return;
        }

        renderDashboard(data);

    } catch {
        showError("Server error while fetching data");
    }
}

// ---------------- RENDER DASHBOARD ----------------
function renderDashboard(data) {

    // -------- SAFETY SCORE RING --------
    const score = data.safety_score;
    const offset = 314 - (314 * score) / 100;

    setTimeout(() => {
        document.getElementById("score-panel").style.display = "block";

        document.getElementById("score-num").innerText = score;
        document.getElementById("ring").style.strokeDashoffset = offset;

        const label = document.getElementById("safety-label");

        if (score > 70) {
            label.innerText = "SAFE";
            label.style.color = "#06d6a0";
        } else if (score > 40) {
            label.innerText = "MODERATE";
            label.style.color = "#ffd166";
        } else {
            label.innerText = "DANGEROUS";
            label.style.color = "#ff4455";
        }

        const sev = document.getElementById("sev-badge");
        sev.className = `sev-badge sev-${data.severity}`;
        sev.innerHTML = `<span class="sev-dot"></span>${data.severity}`;

    }, 200);

    // -------- PROBABILITY GRID (SAFE CHECK) --------
    document.getElementById("prob-panel").style.display = "block";

    let probHTML = "";

    if (data.risk_breakdown) {
        data.risk_breakdown.slice(0, 6).forEach(item => {
            probHTML += `
                <div class="prob-item">
                    <div class="prob-val">${item.crime_rate}</div>
                    <div class="prob-name">${item.crime_type}</div>
                </div>
            `;
        });
    }

    document.getElementById("prob-grid").innerHTML = probHTML;

    // -------- RIGHT PANEL --------
    let html = `
        <div class="top-stats">
            <div class="stat-card red">
                <div class="stat-val">${data.crime_count}</div>
                <div class="stat-lbl">Total Cases</div>
            </div>
            <div class="stat-card orange">
                <div class="stat-val">${data.crime_rate}</div>
                <div class="stat-lbl">Crime Rate</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-val">${data.safety_score}</div>
                <div class="stat-lbl">Safety Score</div>
            </div>
        </div>
    `;

    // -------- DISTRICT COMPARISON (SAFE CHECK) --------
    if (data.comparisons) {
        html += `<div class="chart-area"><div class="chart-title">District Comparison</div>`;

        data.comparisons.slice(0, 8).forEach(c => {
            html += `
                <div class="bar-row">
                    <div class="bar-label">${c.district}</div>
                    <div class="bar-track">
                        <div class="bar-fill" style="width:${c.crime_rate}%">
                            <span class="bar-num">${c.crime_rate}</span>
                        </div>
                    </div>
                </div>
            `;
        });

        html += `</div>`;
    }

    // -------- RISK BREAKDOWN (SAFE CHECK) --------
    if (data.risk_breakdown) {
        html += `<div class="chart-area"><div class="chart-title">Risk Breakdown</div>`;

        data.risk_breakdown.slice(0, 8).forEach(r => {
            html += `
                <div class="bar-row">
                    <div class="bar-label">${r.crime_type}</div>
                    <div class="bar-track">
                        <div class="bar-fill" style="width:${r.crime_rate}%">
                            <span class="bar-num">${r.crime_rate}</span>
                        </div>
                    </div>
                </div>
            `;
        });

        html += `</div>`;
    }

    document.getElementById("right-panel").innerHTML = html;
}

// ---------------- PAGE SWITCH ----------------
function showPage(pageNumber) {
    document.querySelectorAll(".page").forEach(p => p.classList.remove("active"));
    document.getElementById("p" + pageNumber).classList.add("active");
}