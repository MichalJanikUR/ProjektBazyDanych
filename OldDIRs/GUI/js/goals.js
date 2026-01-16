function openGoalModal() {
    document.getElementById('goalModal').style.display = 'block';
}

function closeGoalModal() {
    document.getElementById('goalModal').style.display = 'none';
}

function updateGoal(newGoal) {
    fetch('update_goal.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'goal=' + newGoal
    }).then(() => {
        location.reload(); 
    });
}

// Zamknij modal po kliknięciu poza niego
window.onclick = function(event) {
    const modal = document.getElementById('goalModal');
    if (event.target == modal) {
        closeGoalModal();
    }
}