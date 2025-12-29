<?php
include 'includes/auth.php'; // Obsługuje session_start i sprawdzanie logowania
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

// --- LOGIKA DANYCH ---
try {
    // Streak
    $stmt = $pdo->prepare("SELECT crud.calculate_workout_streak(:user_id, 4) as streak");
    $stmt->execute(['user_id' => $user_id]);
    $current_streak = $stmt->fetchColumn() ?: 0;

    // Typ Treningu
    $stmt = $pdo->prepare("SELECT public.detect_training_split(:user_id) as training_type");
    $stmt->execute(['user_id' => $user_id]);
    $training_type = $stmt->fetchColumn() ?: 'Brak treningów';

    // TDEE / Kalorie
    $stmt = $pdo->prepare("SELECT public.calculate_user_tdee(:user_id) as tdee");
    $stmt->execute(['user_id' => $user_id]);
    $calories_today = $stmt->fetchColumn() ?: 0;

    // Listy do wykresu
    $muscle_groups = $pdo->query("SELECT * FROM public.muscle_groups ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);
    $exercises_list = $pdo->query("SELECT id, name, muscle_group_id FROM public.exercises ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);

    // Dane wykresu
    $exercise_id = $_GET['exercise_id'] ?? 6; 
    $stmt = $pdo->prepare("SELECT * FROM public.get_exercise_volume_progression(:user_id, :ex_id)");
    $stmt->execute(['user_id' => $user_id, 'ex_id' => $exercise_id]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $chart_labels = [];
    $chart_data = [];
    foreach ($results as $row) {
        $chart_labels[] = date('d.m', strtotime($row['workout_date']));
        $chart_data[] = (float)$row['total_volume'];
    }
} catch (PDOException $e) {
    echo "Szczegóły błędu: " . $e->getMessage();
    exit;
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Dashboard</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/dashboard.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="icon" href="image/AwareFit-logo.png">
</head>
<body class="dashboard-body">

    <?php include 'includes/header.php'; ?>

    <main class="app-content">

    <section class="training-type-section">
            <div class="info-card wide-card">
                <i class="fa-solid fa-brain icon-gradient"></i>
                <div class="card-data">
                    <span class="label">Wykryty typ treningu</span>
                    <span class="value"><?php echo htmlspecialchars($training_type); ?></span>
                </div>
            </div>
        </section>


        <section class="dashboard-grid">
            <div class="info-card">
                <i class="fa-solid fa-bolt icon-gradient"></i>
                <div class="card-data"><span class="label">Streak</span><span class="value"><?php echo $current_streak; ?> dni</span></div>
            </div>

            <div class="info-card" onclick="openGoalModal()" style="cursor: pointer;">
                <i class="fa-solid fa-fire icon-gradient"></i>
                <div class="card-data"><span class="label">Twój Cel</span><span class="value"><?php echo $calories_today; ?> <small>kcal</small></span></div>
            </div>
        </section>

        <section class="chart-section">
            <div class="chart-container">
                <div class="chart-header" style="margin-bottom: 20px;">
                    <h3 style="color: var(--text-main); font-size: 1rem; font-weight: 600; display: flex; align-items: center;">
                        <i class="fa-solid fa-chart-line" style="margin-right: 10px; color: #57ca22;"></i>
                        Progres Objętości
                    </h3>
                </div>

                <div class="chart-controls" style="margin-bottom: 15px; display: flex; justify-content: space-between;">
                    <select class="chart-select" id="muscleGroupSelect" style="width: 48%;">
                        <option value="">Wybierz partię</option>
                        <?php foreach ($muscle_groups as $mg): ?>
                            <option value="<?php echo $mg['id']; ?>" <?php 
                                $mg_match = false;
                                foreach($exercises_list as $el) if($el['id'] == $exercise_id && $el['muscle_group_id'] == $mg['id']) $mg_match = true;
                                echo $mg_match ? 'selected' : ''; 
                            ?>><?php echo htmlspecialchars($mg['name']); ?></option>
                        <?php endforeach; ?>
                    </select>
                    
                    <select class="chart-select" id="exerciseSelect" style="width: 48%;">
                        <option value="">Wybierz ćwiczenie</option>
                    </select>
                </div>

                <div style="height: 220px; position: relative;">
                    <canvas id="volumeChart"></canvas>
                    <?php if (empty($chart_data)): ?>
                        <div id="noDataMessage" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #444; text-align: center;">Brak danych...</div>
                    <?php endif; ?>
                </div>
            </div>
        </section>

        <section class="action-section">
            <button class="main-cta-btn"><i class="fa-solid fa-plus"></i> ROZPOCZNIJ TRENING</button>
        </section>

    </main>

    <?php include 'includes/navbar.php'; ?>

    <div id="goalModal" class="modal">
        <div class="modal-content">
            <h3>Wybierz swój cel</h3>
            <button onclick="updateGoal('Cut')" class="goal-btn cut">Redukcja (-500 kcal)</button>
            <button onclick="updateGoal('Maintenance')" class="goal-btn">Utrzymanie (0 kcal)</button>
            <button onclick="updateGoal('Bulk')" class="goal-btn bulk">Masa (+300 kcal)</button>
            <button onclick="closeGoalModal()" class="close-btn">Anuluj</button>
        </div>
    </div>

<script>
        const allExercises = <?php echo json_encode($exercises_list); ?>;
        const chartLabels = <?php echo json_encode($chart_labels); ?>;
        const chartData = <?php echo json_encode($chart_data); ?>;
        const currentExerciseId = <?php echo (int)$exercise_id; ?>;
    </script>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script src="js/goals.js?v=<?php echo time(); ?>"></script>
<script src="js/dashboard.js?v=<?php echo time(); ?>"></script>
</body>
</html>