// --- 1. LOGIKA FILTROWANIA I ZAZNACZANIA ---
const muscleSelect = document.getElementById('muscleGroupSelect');
const exSelect = document.getElementById('exerciseSelect');

/**
 * Funkcja wypełnia listę ćwiczeń dla danej partii
 */
function populateExercises(mgId, selectedExId = null) {
    exSelect.innerHTML = '<option value="">Wybierz ćwiczenie</option>';
    
    if (!mgId) return;

    const filtered = allExercises.filter(ex => ex.muscle_group_id == mgId);
    
    filtered.forEach(ex => {
        const opt = document.createElement('option');
        opt.value = ex.id;
        opt.text = ex.name;
        if (selectedExId && ex.id == selectedExId) {
            opt.selected = true;
        }
        exSelect.add(opt);
    });
}

// Inicjalizacja przy starcie
if (muscleSelect && muscleSelect.value) {
    populateExercises(muscleSelect.value, currentExerciseId);
}

// Eventy
if (muscleSelect) {
    muscleSelect.addEventListener('change', function() {
        populateExercises(this.value);
    });
}

if (exSelect) {
    exSelect.addEventListener('change', function() {
        if (this.value) {
            window.location.href = 'dashboard.php?exercise_id=' + this.value;
        }
    });
}

// --- 2. KONFIGURACJA WYKRESU ---
const canvasElement = document.getElementById('volumeChart');
if (canvasElement && chartData.length > 0) {
    const ctx = canvasElement.getContext('2d');
    const gradient = ctx.createLinearGradient(0, 0, 0, 200);
    gradient.addColorStop(0, 'rgba(87, 202, 34, 0.4)');
    gradient.addColorStop(1, 'rgba(0, 191, 255, 0)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: chartLabels,
            datasets: [{
                label: 'Suma kg',
                data: chartData,
                borderColor: '#57ca22',
                backgroundColor: gradient,
                fill: true,
                tension: 0.4,
                borderWidth: 3,
                pointBackgroundColor: '#fff',
                pointRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { grid: { color: '#2a2a2a' }, ticks: { color: '#949494' } },
                x: { grid: { display: false }, ticks: { color: '#949494' } }
            }
        }
    });
}

// --- OBSŁUGA TRENINGU W TOKU ---
function checkActiveWorkout() {
    if (typeof currentUserId === 'undefined') return;

    const storageKey = `activeWorkout_${currentUserId}`;
    const activeWorkout = localStorage.getItem(storageKey);
    const btn = document.getElementById('start-workout-btn');
    
    if (activeWorkout && btn) {
        try {
            const data = JSON.parse(activeWorkout);
            if (data && Array.isArray(data) && data.length > 0) {
                btn.innerHTML = '<i class="fa-solid fa-play"></i> KONTYNUUJ TRENING';
                btn.style.background = 'linear-gradient(135deg, #f1c40f, #f39c12)';
                btn.style.boxShadow = '0 4px 15px rgba(243, 156, 18, 0.4)';
            }
        } catch (e) {
            console.error("Błąd parsowania treningu:", e);
        }
    }
}

// --- OBSŁUGA MODALA MAKROSKŁADNIKÓW ---
function openMacroModal() {
    const modal = document.getElementById('macroModal');
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeMacroModal(event) {
    const modal = document.getElementById('macroModal');
    if (!modal) return;

    // Zamyka jeśli wywołano bez eventu (przycisk X) lub kliknięto w tło (overlay)
    if (!event || event.target.id === 'macroModal' || event.target.classList.contains('close-btn')) {
        modal.classList.remove('active');
        document.body.style.overflow = 'auto';
    }
}

// --- INICJALIZACJA ---
document.addEventListener('DOMContentLoaded', function() {
    // 1. Sprawdź czy jest aktywny trening
    checkActiveWorkout();

    // 2. Podepnij kliknięcie w kartę kalorii
    const calorieCard = document.querySelector('.dashboard-grid .info-card:nth-child(2)');
    if (calorieCard) {
        calorieCard.style.cursor = 'pointer';
        calorieCard.addEventListener('click', openMacroModal);
    }

    // 3. Obsługa zamykania modala (X w nagłówku)
    const closeBtn = document.querySelector('#macroModal .close-btn');
    if (closeBtn) {
        closeBtn.addEventListener('click', () => closeMacroModal());
    }
});