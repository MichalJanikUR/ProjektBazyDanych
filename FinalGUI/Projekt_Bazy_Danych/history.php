<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // Pobranie historii przy użyciu funkcji tabelarycznej.
    $stmt = $pdo->prepare("
        SELECT *, 
        public.calculate_workout_total_volume(workout_id) as db_total_volume 
        FROM public.get_user_workout_history(:user_id::integer)
    ");
    $stmt->execute(['user_id' => $user_id]);
    $raw_data = $stmt->fetchAll(\PDO::FETCH_ASSOC);

    $history = [];
    foreach ($raw_data as $row) {
        $w_id = $row['workout_id'];
        $ex_name = $row['exercise_name'];

        // Grupowanie danych w tablicy asocjacyjnej
        if (!isset($history[$w_id])) {
            $history[$w_id] = [
                'display_number' => $row['user_workout_no'],
                'date'           => $row['workout_date'],
                'duration'       => $row['duration'],
                'total_volume'   => $row['db_total_volume'], 
                'exercises'      => []
            ];
        }

        if (!isset($history[$w_id]['exercises'][$ex_name])) {
            $history[$w_id]['exercises'][$ex_name] = [];
        }

        $history[$w_id]['exercises'][$ex_name][] = [
            'weight'  => $row['weight'],
            'reps'    => $row['reps'],
            'set_no'  => $row['set_number']
        ];
    }
} catch (\PDOException $e) {
    // Logowanie błędu i wyświetlenie bezpiecznego komunikatu
    error_log("Błąd historii: " . $e->getMessage());
    $error_msg = "Nie udało się załadować historii treningów.";
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Historia</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/history.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="image/AwareFit-logo.png">
</head>
<body>
    <?php include 'includes/header.php'; ?>

    <main class="history-container">
        <?php if (empty($history)): ?>
            <p class="empty-msg">Nie znaleziono treningów.</p>
        <?php endif; ?>

        <?php foreach ($history as $w_id => $workout): ?>
            <div class="workout-accordion">
                <div class="accordion-header" onclick="toggleAccordion(this)">
                    <div class="workout-main-info">
                        <span class="workout-title">Trening #<?php echo $workout['display_number']; ?></span>
                        <div class="workout-meta">
                            <span><i class="fa-regular fa-calendar"></i> <?php echo date('d.m.Y', strtotime($workout['date'])); ?></span>
                            <span><i class="fa-regular fa-clock"></i> <?php echo date('H:i', strtotime($workout['date'])); ?></span>
                        </div>
                    </div>
                    <div class="workout-stats">
                        <span class="volume-tag"><?php echo number_format($workout['total_volume'], 0, ',', ' '); ?> <small>kg</small></span>
                        <span class="duration-text"><?php echo substr($workout['duration'], 0, 5); ?> h</span>
                    </div>
                    <i class="fa-solid fa-chevron-down chevron"></i>
                </div>

                <div class="accordion-content">
                    <?php foreach ($workout['exercises'] as $ex_name => $sets): ?>
                        <div class="ex-summary-item">
                            <span class="ex-name"><?php echo htmlspecialchars($ex_name); ?></span>
                            <div class="sets-table">
                                <?php foreach ($sets as $set): ?>
                                    <div class="set-row-history">
                                        <div class="set-cell no"><?php echo $set['set_no']; ?></div>
                                        <div class="set-cell"><?php echo $set['weight']; ?> kg</div>
                                        <div class="set-cell"><?php echo $set['reps']; ?> powt.</div>
                                    </div>
                                <?php endforeach; ?>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endforeach; ?>
    </main>

    <?php include 'includes/navbar.php'; ?>
    <script src="js/history.js"></script>
</body>
</html>