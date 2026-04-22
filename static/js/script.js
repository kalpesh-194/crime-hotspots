let selectedCrimeType = "Murder";

// -------- LOAD STATES --------
window.onload = async () => {
    const res = await fetch("/api/states");
    const states = await res.json();

    const stateBox = document.getElementById("state-sel");

    states.forEach(s => {
        stateBox.innerHTML += `<option value="${s}">${s}</option>`;
    });
};


// -------- LOAD DISTRICTS --------
async function onStateChange() {
    const state = document.getElementById("state-sel").value;

    const res = await fetch(`/api/districts?state=${state}`);
    const districts = await res.json();

    const districtBox = document.getElementById("district-sel");
    districtBox.innerHTML = `<option value="">--Select--</option>`;

    districts.forEach(d => {
        districtBox.innerHTML += `<option value="${d}">${d}</option>`;
    });
}


// -------- SELECT CRIME --------
function selectCrime(el) {
    document.querySelectorAll(".cpill").forEach(c => c.classList.remove("active"));
    el.classList.add("active");

    selectedCrimeType = el.getAttribute("data-crime");

    compute();
}


// -------- FETCH DATA --------
async function compute() {
    const state = document.getElementById("state-sel").value;
    const district = document.getElementById("district-sel").value;

    if (!state || !district) return;

    const res = await fetch(`/api/crime?state=${state}&district=${district}&type=${selectedCrimeType}`);
    const data = await res.json();

    console.log(data);

    alert(
        `Cases: ${data.crime_count}\n` +
        `Severity: ${data.severity}\n` +
        `Safety Score: ${data.safety_score}`
    );
}

