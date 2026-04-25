// ================= GLOBAL =================
let map = null;
let marker = null;
let selectedCrime = "Murder";


// ================= PAGE SWITCH =================
function showPage(id) {
    document.querySelectorAll(".page").forEach(p => p.classList.remove("active"));
    document.getElementById("p" + id).classList.add("active");

    // ✅ Initialize map when dashboard opens
    if (id === 2) {
        setTimeout(() => {
            initMap();
        }, 300);
    }
}


// ================= INIT MAP (INDIA DEFAULT) =================
function initMap() {
    if (map !== null) return; // prevent re-init

    map = L.map("map").setView([22.9734, 78.6569], 5); // 🇮🇳 India center

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 19
    }).addTo(map);

    console.log("Map Loaded ✅");
}


// ================= UPDATE MAP =================
function updateMap(lat, lng) {
    if (!map) return;

    map.setView([lat, lng], 10);

    if (marker) {
        marker.setLatLng([lat, lng]);
    } else {
        marker = L.marker([lat, lng]).addTo(map);
    }
}


// ================= CRIME SELECT =================
function selectCrime(el) {
    document.querySelectorAll(".cpill").forEach(p => p.classList.remove("active"));
    el.classList.add("active");

    selectedCrime = el.dataset.crime;

    compute();
}


// ================= LOAD STATES =================
async function loadStates() {
    const res = await fetch("/api/states");
    const data = await res.json();

    const sel = document.getElementById("state-sel");
    sel.innerHTML = `<option value="">— Select State —</option>`;

    data.forEach(s => {
        sel.innerHTML += `<option value="${s}">${s}</option>`;
    });
}


// ================= STATE CHANGE =================
async function onStateChange() {
    const state = document.getElementById("state-sel").value;
    const dSel = document.getElementById("district-sel");

    if (!state) return;

    dSel.innerHTML = `<option>Loading...</option>`;

    const res = await fetch(`/api/districts?state=${state}`);
    const data = await res.json();

    dSel.innerHTML = `<option value="">— Select District —</option>`;
    data.forEach(d => {
        dSel.innerHTML += `<option value="${d}">${d}</option>`;
    });
}


// ================= MAIN COMPUTE =================
async function compute() {
    const state = document.getElementById("state-sel").value;
    const district = document.getElementById("district-sel").value;

    if (!state || !district) return;

    try {
        const res = await fetch(`/api/crime?state=${state}&district=${district}&type=${selectedCrime}`);
        const data = await res.json();

        updateSafetyScore(data);

        // ✅ Update map using real location
        geocodeAndUpdateMap(state, district);

    } catch (err) {
        console.log("Error:", err);
    }
}


// ================= GEOCODING =================
async function geocodeAndUpdateMap(state, district) {
    const query = `${district}, ${state}, India`;

    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}`;

    const res = await fetch(url);
    const data = await res.json();

    if (!data || data.length === 0) {
        console.log("Location not found");
        return;
    }

    const lat = parseFloat(data[0].lat);
    const lon = parseFloat(data[0].lon);

    updateMap(lat, lon);
}


// ================= SAFETY SCORE =================
function updateSafetyScore(data) {
    document.getElementById("score-panel").style.display = "block";

    document.getElementById("score-num").innerText = data.safety_score;

    const ring = document.getElementById("ring");
    const offset = 314 - (314 * data.safety_score) / 100;
    ring.style.strokeDashoffset = offset;

    const label = document.getElementById("safety-label");

    if (data.safety_score > 70) {
        label.innerText = "SAFE";
        label.style.color = "#06d6a0";
    } else if (data.safety_score > 40) {
        label.innerText = "MODERATE";
        label.style.color = "#ffd166";
    } else {
        label.innerText = "DANGEROUS";
        label.style.color = "#ff4455";
    }

    document.getElementById("sev-badge").innerText = data.severity;
}


// ================= START =================
window.onload = function () {
    loadStates();
};