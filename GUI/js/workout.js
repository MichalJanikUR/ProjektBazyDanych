const storageKey = `activeWorkout_${currentUserId}`;
const timerKey = `workoutStartTime_${currentUserId}`;

let currentWorkout = JSON.parse(localStorage.getItem(storageKey)) || []; 
let activeExercise = null;

document.addEventListener('DOMContentLoaded', () => {
    updateActiveWorkoutUI();
    startTimer(); 
});

function saveToLocalStorage() {
    localStorage.setItem(storageKey, JSON.stringify(currentWorkout));
}

function showStep(stepId) {
    document.querySelectorAll('.workout-step').forEach(step => {
        step.style.display = 'none';
        step.classList.remove('active');
    });
    const target = document.getElementById('step-' + stepId);
    if (target) {
        target.style.display = 'flex';
        target.classList.add('active');
    }
}

function selectMuscleGroup(muscleName) {
    document.getElementById('selected-muscle-label').innerText = muscleName;
    const list = document.getElementById('exercise-list');
    list.innerHTML = '<p style="text-align:center;">Ładowanie...</p>';
    
    fetch(`get_exercises.php?muscle=${encodeURIComponent(muscleName)}`)
        .then(res => res.json())
        .then(data => {
            list.innerHTML = '';
            data.forEach(ex => {
                const div = document.createElement('div');
                div.className = 'list-item';
                div.innerText = ex.exercise_name;
                div.onclick = () => selectExercise(ex.exercise_id, ex.exercise_name);
                list.appendChild(div);
            });
            showStep('exercises');
        });
}

// NOWA FUNKCJA: Aktualizacja placeholderów na podstawie poprzedniego treningu
function updatePlaceholders(exerciseId, setNo) {
    fetch(`get_last_stats.php?exercise_id=${exerciseId}&set_no=${setNo}`)
        .then(res => res.json())
        .then(data => {
            const weightInput = document.getElementById('input-weight');
            const repsInput = document.getElementById('input-reps');
            
            if (data && (data.last_weight > 0 || data.last_reps > 0)) {
                weightInput.placeholder = data.last_weight;
                repsInput.placeholder = data.last_reps;
            } else {
                weightInput.placeholder = "0";
                repsInput.placeholder = "0";
            }
        })
        .catch(err => console.error("Błąd pobierania statystyk:", err));
}

function selectExercise(id, name) {
    activeExercise = { id: String(id), name: name };
    document.getElementById('exercise-id-input').value = id;
    document.getElementById('selected-exercise-label').innerText = name;
    
    // Na start pobieramy placeholdery dla pierwszej serii
    updatePlaceholders(id, 1);
    
    updateSetCounter();
    updateCurrentExerciseSetsUI(); 
    showStep('log-set');
}

// --- FUNKCJE USUWANIA ---

function deleteSet(exerciseId, setIndex) {
    const exercise = currentWorkout.find(ex => String(ex.exercise_id) === String(exerciseId));
    if (exercise) {
        exercise.sets.splice(setIndex, 1);
        
        if (exercise.sets.length === 0) {
            currentWorkout = currentWorkout.filter(ex => String(ex.exercise_id) !== String(exerciseId));
        }
        
        saveToLocalStorage();
        updateActiveWorkoutUI();
        updateCurrentExerciseSetsUI();
        updateSetCounter();

        // Po usunięciu serii aktualizujemy placeholder dla obecnego (nowego) numeru serii
        const nextSetNo = exercise.sets.length + 1;
        updatePlaceholders(exerciseId, nextSetNo);
    }
}

function deleteExercise(exerciseId) {
    if (confirm("Czy na pewno chcesz usunąć to ćwiczenie wraz ze wszystkimi seriami?")) {
        currentWorkout = currentWorkout.filter(ex => String(ex.exercise_id) !== String(exerciseId));
        saveToLocalStorage();
        updateActiveWorkoutUI();
        
        if (activeExercise && String(activeExercise.id) === String(exerciseId)) {
            activeExercise = null;
            showStep('workout-session');
        }
    }
}

// --- LOGOWANIE SERII ---

document.getElementById('logSetForm').onsubmit = function(e) {
    e.preventDefault();
    const weight = document.getElementById('input-weight').value;
    const reps = document.getElementById('input-reps').value;

    if (!weight || !reps) return;

    let exerciseEntry = currentWorkout.find(ex => String(ex.exercise_id) === String(activeExercise.id));
    if (exerciseEntry) {
        exerciseEntry.sets.push({ weight, reps });
    } else {
        exerciseEntry = {
            exercise_id: activeExercise.id,
            exercise_name: activeExercise.name,
            sets: [{ weight, reps }]
        };
        currentWorkout.push(exerciseEntry);
    }

    saveToLocalStorage();
    updateCurrentExerciseSetsUI();
    updateSetCounter();
    updateActiveWorkoutUI();

    // Pobieramy placeholder dla KOLEJNEJ serii
    const nextSetNo = exerciseEntry.sets.length + 1;
    updatePlaceholders(activeExercise.id, nextSetNo);

    document.getElementById('input-reps').value = "";
    document.getElementById('input-reps').focus();
    
    const btn = document.getElementById('add-set-btn');
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-check"></i> DODANO!';
    setTimeout(() => btn.innerHTML = originalText, 800);
};

function updateCurrentExerciseSetsUI() {
    const setsContainer = document.getElementById('current-exercise-sets');
    if (!setsContainer || !activeExercise) return;

    const exerciseEntry = currentWorkout.find(ex => String(ex.exercise_id) === String(activeExercise.id));
    if (!exerciseEntry || exerciseEntry.sets.length === 0) {
        setsContainer.innerHTML = '';
        return;
    }

    let html = '<h4 style="color: var(--text-dim); font-size: 0.8rem; margin-bottom: 10px;">DODANE SERIE:</h4>';
    exerciseEntry.sets.forEach((set, index) => {
        html += `
            <div style="background: #1f2022; padding: 12px; border-radius: 12px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; border: 1px solid #333;">
                <span style="color: #57ca22; font-weight: 700;">#${index + 1}</span>
                <span style="color: white;">${set.weight} kg  x  ${set.reps}</span>
                <button type="button" onclick="deleteSet('${activeExercise.id}', ${index})" style="background:none; border:none; color:#ff4444; cursor:pointer; padding:5px;">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </div>`;
    });
    setsContainer.innerHTML = html;
}

function updateSetCounter() {
    if (!activeExercise) return;
    const exerciseEntry = currentWorkout.find(ex => String(ex.exercise_id) === String(activeExercise.id));
    const count = exerciseEntry ? exerciseEntry.sets.length + 1 : 1;
    document.getElementById('set-counter').innerText = `Seria #${count}`;
}

function updateActiveWorkoutUI() {
    const logContainer = document.getElementById('active-workout-log');
    if (!logContainer) return;

    if (!currentWorkout || currentWorkout.length === 0) {
        logContainer.innerHTML = `
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 20px; opacity: 0.5;">
                <i class="fa-solid fa-clipboard-list" style="font-size: 2rem; margin-bottom: 10px;"></i>
                <p style="margin: 0; font-size: 0.9rem;">Brak ćwiczeń w tej sesji.</p>
            </div>
        `;
        return;
    }

    logContainer.innerHTML = currentWorkout.map(ex => `
        <div class="exercise-summary-card" style="background: #1f2022; border: 1px solid #333; border-radius: 20px; padding: 18px; margin-bottom: 15px; width: 100%; box-sizing: border-box;">
            
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h4 style="color: white; font-size: 0.9rem; font-weight: 600; margin: 0; display: flex; align-items: center; gap: 8px; text-transform: uppercase;">
                    <i class="fa-solid fa-dumbbell" style="color: #57ca22; font-size: 0.8rem;"></i> ${ex.exercise_name}
                </h4>
                <button type="button" onclick="deleteExercise('${ex.exercise_id}')" style="background: none; border: none; color: #ff4444; cursor: pointer; padding: 5px; font-size: 1.2rem; opacity: 0.7; transition: 0.2s;" onmouseover="this.style.opacity='1'" onmouseout="this.style.opacity='0.7'">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1.5fr 1.2fr; gap: 8px; margin-bottom: 8px; padding: 0 5px;">
                <span style="color: #666; font-size: 0.6rem; text-transform: uppercase; font-weight: 700; text-align: center;">Seria</span>
                <span style="color: #666; font-size: 0.6rem; text-transform: uppercase; font-weight: 700; text-align: center;">Ciężar</span>
                <span style="color: #666; font-size: 0.6rem; text-transform: uppercase; font-weight: 700; text-align: center;">Powt.</span>
            </div>

            <div class="sets-summary-list" style="display: flex; flex-direction: column; gap: 6px;">
                ${ex.sets.map((set, i) => `
                    <div class="set-row" style="display: grid; grid-template-columns: 1fr 1.5fr 1.2fr; gap: 8px; align-items: center;">
                        <div style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 10px; padding: 6px 0; display: flex; justify-content: center; align-items: center;">
                            <span style="font-size: 0.9rem; color: #57ca22; font-weight: 800;">${i + 1}</span>
                        </div>
                        <div style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 10px; padding: 6px 0; display: flex; justify-content: center; align-items: center;">
                            <span style="font-size: 0.9rem; color: white; font-weight: 800;">${set.weight}<small style="color: #57ca22; font-size: 0.7rem; margin-left: 1px;">kg</small></span>
                        </div>
                        <div style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 10px; padding: 6px 0; display: flex; justify-content: center; align-items: center;">
                            <span style="font-size: 0.9rem; color: white; font-weight: 800;">${set.reps}</span>
                        </div>
                    </div>
                `).join('')}
            </div>
        </div>
    `).join('');
}

function finishWorkout() {
    if (currentWorkout.length === 0) {
        alert("Dodaj przynajmniej jedno ćwiczenie!");
        return;
    }
    
    if (!confirm("Czy na pewno chcesz zakończyć i zapisać trening?")) return;

    const startTime = localStorage.getItem(timerKey);
    const durationSec = Math.floor((Date.now() - startTime) / 1000);

    const payload = {
        duration: durationSec,
        workout: currentWorkout 
    };

    fetch('save_workout.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            localStorage.removeItem(storageKey); 
            localStorage.removeItem(timerKey);
            window.location.href = 'dashboard.php';
        } else {
            alert("Błąd: " + data.message);
        }
    })
    .catch(err => console.error("Błąd wysyłania:", err));
}

function startTimer() {
    let storedTime = localStorage.getItem(timerKey);
    let startTime = storedTime ? parseInt(storedTime) : Date.now();
    if (!storedTime) localStorage.setItem(timerKey, startTime);

    const update = () => {
        const diff = Math.floor((Date.now() - startTime) / 1000);
        const seconds = diff > 0 ? diff : 0;
        const h = Math.floor(seconds / 3600).toString().padStart(2, '0');
        const m = Math.floor((seconds % 3600) / 60).toString().padStart(2, '0');
        const s = (seconds % 60).toString().padStart(2, '0');
        const timerEl = document.getElementById('workout-timer');
        if (timerEl) timerEl.innerText = `${h}:${m}:${s}`;
    };
    update();
    setInterval(update, 1000);
}