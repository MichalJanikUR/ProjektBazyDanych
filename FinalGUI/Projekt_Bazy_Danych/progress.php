<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // Pobranie liczby treningów z ostatnich 7 dni przy użyciu rzutowania typów
    $stmt_streak = $pdo->prepare("SELECT public.get_weekly_workout_count(:id::integer)");
    $stmt_streak->execute(['id' => $user_id]);
    $weekly_workouts = $stmt_streak->fetchColumn() ?: 0;    $stmt_streak->execute(['id' => $user_id]);
    $weekly_workouts = $stmt_streak->fetchColumn() ?: 0;

    // Pobranie typu splitu za pomocą funkcji analitycznej
    $stmt_split = $pdo->prepare("SELECT public.detect_training_split(:id::integer)");
    $stmt_split->execute(['id' => $user_id]);
    $training_split = $stmt_split->fetchColumn() ?: 'Brak danych';

    // Definicja ćwiczeń "Big 3" do obliczenia rekordu estymowanego (1RM)
    $bigThree = [
        ['id' => 6, 'name' => 'Wyciskanie na ławce'],
        ['id' => 69, 'name' => 'Przysiad ze sztangą'],
        ['id' => 59, 'name' => 'Martwy ciąg']
    ];

    $records = [];
    foreach ($bigThree as $exercise) {
        // Wywołanie funkcji obliczającej 1RM (np. wzorem Brzyckiego lub Epleya w SQL)
        $stmt_rm = $pdo->prepare("SELECT public.calculate_exercise_1rm(:u::integer, :e::integer)");
        $stmt_rm->execute(['u' => $user_id, 'e' => $exercise['id']]);
        $val = $stmt_rm->fetchColumn();
        $records[] = [
            'name' => $exercise['name'],
            'val' => $val ?: 0
        ];
    }

    // Pobranie balansu strukturalnego (procentowy udział partii mięśniowych w objętości)
    $stmt_balance = $pdo->prepare("SELECT * FROM public.get_user_muscle_balance(:id::integer)");
    $stmt_balance->execute(['id' => $user_id]);
    $balance_data = $stmt_balance->fetchAll(\PDO::FETCH_ASSOC);

    // Wyznaczenie partii pominiętych w ostatnim cyklu treningowym
    $trained_groups = array_column($balance_data, 'muscle_group_name');
    $stmt_all_mg = $pdo->query("SELECT name FROM crud.get_all_muscle_groups()");
    $all_groups = $stmt_all_mg->fetchAll(\PDO::FETCH_COLUMN);
    $missing_groups = array_diff($all_groups, $trained_groups);

    // Porównanie objętości tydzień do tygodnia (Trend progresji)
    $stmt_comp = $pdo->prepare("SELECT * FROM public.get_volume_comparison(:id::integer)");
    $stmt_comp->execute(['id' => $user_id]);
    $comp_data = $stmt_comp->fetch(\PDO::FETCH_ASSOC);

    $curr_vol = $comp_data['current_volume'] ?? 0;
    $prev_vol = $comp_data['previous_volume'] ?? 0;
    $diff_percent = 0;
    $trend_class = 'neutral';

    if ($prev_vol > 0) {
        $diff_percent = (($curr_vol - $prev_vol) / $prev_vol) * 100;
        $trend_class = ($diff_percent >= 0) ? 'positive' : 'negative';
    } elseif ($curr_vol > 0) {
        $diff_percent = 100; 
        $trend_class = 'positive';
    }

} catch (\PDOException $e) {
    error_log("Błąd progress.php: " . $e->getMessage());
    die("Wystąpił błąd podczas generowania statystyk progresu.");
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Twój Progres</title>
    <link rel="stylesheet" href="css/global.css">
    <link rel="stylesheet" href="css/progress.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="image/AwareFit-logo.png">

</head>
<body class="dashboard-body">
    <?php include 'includes/header.php'; ?>

    <main class="app-content">

        <div class="progress-card streak-card">
            <div class="card-icon-circle">
                <i class="fa-solid fa-brain icon-gradient"></i>
            </div>
            <div class="card-main-info">
                <span class="label">System Treningowy</span>
                <h3 class="value"><?php echo $training_split; ?></h3>
                <p class="sub-value">Aktywność w tyg: <strong><?php echo $weekly_workouts; ?> treningi</strong></p>
            </div>
        </div>

<div class="progress-card volume-card">
    <div class="volume-header">
        <div>
            <span class="label">Objętość (Ostatnie 7 dni)</span>
            <h3 class="value"><?php echo number_format($curr_vol, 0, ',', ' '); ?> <small>kg</small></h3>
        </div>
        
        <div class="trend-badge <?php echo $trend_class; ?>">
            <i class="fa-solid <?php echo ($diff_percent >= 0) ? 'fa-caret-up' : 'fa-caret-down'; ?>"></i>
            <span><?php echo abs(round($diff_percent, 1)); ?>%</span>
        </div>
    </div>
    
    <div class="volume-insight">
        <?php if ($diff_percent > 0): ?>
            <p class="text-positive">Progresujesz! Przerzuciłeś o <?php echo number_format($curr_vol - $prev_vol, 0, ',', ' '); ?> kg więcej niż w zeszłym tygodniu.</p>
        <?php elseif ($diff_percent < 0): ?>
            <p class="text-warning">Objętość spadła. Jeśli to nie tydzień regeneracyjny (deload), zadbaj o regularność.</p>
        <?php else: ?>
            <p class="text-neutral">Utrzymujesz stałą intensywność. Dobry moment na dołożenie 1-2 kg do głównych bojów.</p>
        <?php endif; ?>
    </div>
</div>

<h3 class="sub-title">Balans Strukturalny (7 dni)</h3>
<div class="balance-container">
    <?php if (empty($balance_data)): ?>
        <p style="color: var(--text-dim); font-size: 0.8rem;">Zapisz trening, aby zobaczyć rozkład partii.</p>
    <?php else: ?>
        <?php foreach ($balance_data as $row): ?>
            <div class="balance-item">
                <div class="balance-info">
                    <span><?php echo $row['muscle_group_name']; ?></span>
                    <span><?php echo $row['volume_percentage']; ?>%</span>
                </div>
                <div class="balance-bar-bg">
                    <div class="balance-bar-fill" style="width: <?php echo $row['volume_percentage']; ?>%"></div>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php if (!empty($missing_groups) && !empty($balance_data)): ?>
    <div class="missing-parts-container">
        <h4 class="missing-title">
            <i class="fa-solid fa-circle-exclamation"></i> Pominięte w tym tygodniu:
        </h4>
        <div class="missing-tags">
            <?php foreach ($missing_groups as $group): ?>
                <span class="missing-tag"><?php echo htmlspecialchars($group); ?></span>
            <?php endforeach; ?>
        </div>
    </div>
<?php endif; ?>

<h3 class="sub-title">Estymowane 1RM (Big 3)</h3>
<div class="records-grid">
    <?php foreach ($records as $record): ?>
    <div class="record-box">
        <div class="record-top">
            <span><?php echo $record['name']; ?></span>
        </div>
        <div class="record-val">
            <?php 
                // Zaokrąglenie do 1 miejsca po przecinku
                echo number_format((float)$record['val'], 1, '.', ''); 
            ?> 
            <small>kg</small>
        </div>
    </div>
    <?php endforeach; ?>
</div>

    </main>

    <?php include 'includes/navbar.php'; ?>
</body>
</html>