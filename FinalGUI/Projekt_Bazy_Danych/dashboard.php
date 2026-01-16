<?php
include 'includes/auth.php'; 
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // Pobieranie statystyk aktywności (Streak i licznik tygodniowy)
    $stmt = $pdo->prepare("SELECT crud.calculate_workout_streak(:user_id::integer, 4)");    $stmt->execute(['user_id' => $user_id]);
    $current_streak = $stmt->fetchColumn() ?: 0;

    $stmt = $pdo->prepare("SELECT public.get_weekly_workout_count(:user_id::integer)");
    $stmt->execute(['user_id' => $user_id]);
    $weekly_workouts = $stmt->fetchColumn() ?: 0;

    // Analiza systemu treningowego
    $stmt = $pdo->prepare("SELECT public.detect_training_split(:user_id)");
    $stmt->execute(['user_id' => $user_id]);
    $training_type = $stmt->fetchColumn() ?: 'Brak danych';

    // Porównanie objętości treningowej (Trend)
    $stmt = $pdo->prepare("SELECT * FROM public.get_volume_comparison(?)");
    $stmt->execute([$user_id]);
    $comp_data = $stmt->fetch(PDO::FETCH_ASSOC);
    $curr_vol = $comp_data['current_volume'] ?? 0;
    $prev_vol = $comp_data['previous_volume'] ?? 0;
    
    $diff_percent = 0;
    if ($prev_vol > 0) {
        $diff_percent = (($curr_vol - $prev_vol) / $prev_vol) * 100;
    } elseif ($curr_vol > 0) {
        $diff_percent = 100;
    }
    $trend_class = ($diff_percent >= 0) ? 'positive' : 'negative';

    // Dane dietetyczne i makroskładniki
    $stmt = $pdo->prepare("SELECT recommended_calories FROM public.calculate_user_diet_calories(:id)");
    $stmt->execute(['id' => $user_id]);
    $calories_today = $stmt->fetchColumn() ?: 2000;

    $stmt = $pdo->prepare("SELECT * FROM public.get_user_macros(:id)");
    $stmt->execute(['id' => $user_id]);
    $macro_data = $stmt->fetch(PDO::FETCH_ASSOC);

    // Pobieranie danych do filtrów
    $muscle_groups = $pdo->query("SELECT * FROM crud.get_all_muscle_groups() ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);
    $exercises_list = $pdo->query("SELECT id, name, muscle_group_id FROM crud.get_all_exercises() ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);
    
    $exercise_id = isset($_GET['exercise_id']) ? (int)$_GET['exercise_id'] : null; 
    
    $chart_labels = []; 
    $chart_data = [];

    if ($exercise_id) {
        $stmt = $pdo->prepare("SELECT * FROM public.get_exercise_volume_progression(:user_id, :ex_id)");
        $stmt->execute(['user_id' => $user_id, 'ex_id' => $exercise_id]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($results as $row) {
            $chart_labels[] = date('d.m', strtotime($row['workout_date']));
            $chart_data[] = (float)$row['total_volume'];
        }
    }

} catch (\PDOException $e) {
    echo "Wystąpił błąd podczas ładowania danych dashboardu. Spróbuj odświeżyć stronę." . $e->getMessage();
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
        <div class="progress-card wide-card">
    <i class="fa-solid fa-brain dashboard-icon-main"></i>
    <div class="card-main-info">
        <span class="label">System Treningowy</span>
        <h3 class="value"><?php echo htmlspecialchars($training_type); ?></h3>
    </div>
</div>

<div class="progress-card volume-card-simple">
    <i class="fa-solid fa-weight-hanging dashboard-icon-main"></i>
    <div class="volume-header">
        <div class="card-data">
            <span class="label">Objętość (7 dni)</span>
            <h3 class="value"><?php echo number_format($curr_vol, 0, ',', ' '); ?> <small>kg</small></h3>
        </div>
        <div class="trend-badge <?php echo $trend_class; ?>">
            <i class="fa-solid <?php echo ($diff_percent >= 0) ? 'fa-caret-up' : 'fa-caret-down'; ?>"></i>
            <span><?php echo abs(round($diff_percent, 1)); ?>%</span>
        </div>
    </div>
</div>

                <section class="dashboard-grid">
<div class="info-card">
    <i class="fa-solid fa-bolt dashboard-icon-main"></i> 
    <div class="card-data">
        <span class="label">Aktywność</span>
        <span class="value">Treningi: <?php echo $weekly_workouts; ?></span>
    </div>
</div>

    <div class="info-card calorie-card-trigger">
        <i class="fa-solid fa-fire dashboard-icon-main"></i>
        <div class="card-data">
            <span class="label">Twój Cel</span>
            <span class="value"><?php echo $calories_today; ?> <small>kcal</small></span>
        </div>
    </div>
</section>

        <section class="chart-section">
            <div class="chart-container">
                <div class="chart-header">
                    <h3><i class="fa-solid fa-chart-line" style="color: #57ca22;"></i> Progres Objętości</h3>
                </div>

                <div class="chart-controls">
                    <select class="chart-select" id="muscleGroupSelect">
                        <option value="">Wybierz partię</option>
                        <?php 
                        $current_mg_id = 0;
                        if ($exercise_id) {
                            foreach($exercises_list as $ex) {
                                if($ex['id'] == $exercise_id) {
                                    $current_mg_id = $ex['muscle_group_id'];
                                    break;
                                }
                            }
                        }

                        foreach ($muscle_groups as $mg): ?>
                            <option value="<?php echo $mg['id']; ?>" <?php echo ($mg['id'] == $current_mg_id) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($mg['name']); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                    
                    <select class="chart-select" id="exerciseSelect">
                        <option value="">Wybierz ćwiczenie</option>
                        <?php 
                        if ($current_mg_id) {
                            foreach ($exercises_list as $ex) {
                                if($ex['muscle_group_id'] == $current_mg_id) {
                                    echo '<option value="'.$ex['id'].'" '.($ex['id'] == $exercise_id ? 'selected' : '').'>'.htmlspecialchars($ex['name']).'</option>';
                                }
                            }
                        }
                        ?>
                    </select>
                </div>

                <div style="height: 180px; position: relative; display: flex; align-items: center; justify-content: center;">
                    <?php if (!$exercise_id): ?>
                        <div class="chart-info-msg">
                            <i class="fa-solid fa-mouse-pointer"></i>
                            <p>Wybierz partię i ćwiczenie, aby zobaczyć progres</p>
                        </div>
                    <?php elseif (empty($chart_data)): ?>
                        <div class="chart-info-msg">
                            <i class="fa-solid fa-dumbbell"></i>
                            <p>Nie odnotowano treningów dla tego ćwiczenia</p>
                        </div>
                    <?php else: ?>
                        <canvas id="volumeChart"></canvas>
                    <?php endif; ?>
                </div>
            </div>
        </section>

        <section class="action-section">
            <a href="workout.php" class="main-cta-btn">
                <i class="fa-solid fa-play"></i> ROZPOCZNIJ TRENING
            </a>
        </section>
    </main>

    <div id="macroModal" class="modal-overlay" onclick="closeMacroModal(event)">
        <div class="modal-card macro-modal-card" onclick="event.stopPropagation()">
            <div class="modal-header">
                <h3><i class="fa-solid fa-chart-pie"></i> Twoje Makro</h3>
                <button type="button" class="close-btn" onclick="closeMacroModal()">&times;</button>
            </div>
            <div class="macro-details-grid">
                <div class="macro-detail-item">
                    <span class="macro-dot protein"></span>
                    <div class="macro-info">
                        <span class="m-label">Białko</span>
                        <span class="m-val"><?php echo $macro_data['protein_g'] ?? 0; ?> g</span>
                    </div>
                </div>
                <div class="macro-detail-item">
                    <span class="macro-dot fat"></span>
                    <div class="macro-info">
                        <span class="m-label">Tłuszcze</span>
                        <span class="m-val"><?php echo $macro_data['fat_g'] ?? 0; ?> g</span>
                    </div>
                </div>
                <div class="macro-detail-item">
                    <span class="macro-dot carbs"></span>
                    <div class="macro-info">
                        <span class="m-label">Węglowodany</span>
                        <span class="m-val"><?php echo $macro_data['carbs_g'] ?? 0; ?> g</span>
                    </div>
                </div>
            </div>
            <div class="macro-total-footer">
                <span>Suma:</span> <strong><?php echo $calories_today; ?> kcal</strong>
            </div>
        </div>
    </div>

    <?php include 'includes/navbar.php'; ?>
    
    <script>
        const allExercises = <?php echo json_encode($exercises_list); ?>;
        const chartLabels = <?php echo json_encode($chart_labels); ?>;
        const chartData = <?php echo json_encode($chart_data); ?>;
        const currentExerciseId = <?php echo $exercise_id ? (int)$exercise_id : 'null'; ?>;
    </script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="js/goals.js"></script>
    <script src="js/dashboard.js"></script>
</body>
</html>