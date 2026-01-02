<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // Wywołujemy funkcję, która zwraca teraz user_workout_no (1, 2, 3...)
    $stmt = $pdo->prepare("SELECT * FROM public.get_user_workout_history(?)");
    $stmt->execute([$user_id]);
    $raw_data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $history = [];
    foreach ($raw_data as $row) {
        $w_id = $row['workout_id']; // ID z bazy używamy tylko jako klucza do grupowania
        $ex_name = $row['exercise_name'];

        if (!isset($history[$w_id])) {
            $history[$w_id] = [
                'display_number' => $row['user_workout_no'], // Nowy numer kolejny użytkownika
                'date' => $row['workout_date'],
                'duration' => $row['duration'],
                'total_volume' => 0,
                'exercises' => []
            ];
        }

        if (!isset($history[$w_id]['exercises'][$ex_name])) {
            $history[$w_id]['exercises'][$ex_name] = [];
        }

        $history[$w_id]['exercises'][$ex_name][] = [
            'weight' => $row['weight'],
            'reps' => $row['reps'],
            'set_no' => $row['set_number']
        ];
        
        // Sumowanie objętości całego treningu
        $history[$w_id]['total_volume'] += ($row['weight'] * $row['reps']);
    }
} catch (PDOException $e) {
    die("Błąd: " . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historia - AwareFit</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .history-container { padding: 100px 20px 110px; max-width: 600px; margin: 0 auto; }
        
        .workout-accordion {
            background: var(--card-bg);
            border-radius: 20px;
            margin-bottom: 15px;
            border: 1px solid #2a2a2a;
            overflow: hidden;
            transition: 0.3s;
        }

        .accordion-header {
            padding: 18px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            user-select: none;
        }

        .workout-main-info { display: flex; flex-direction: column; gap: 4px; }
        .workout-title { font-weight: 700; color: var(--text-main); font-size: 1rem; }
        .workout-meta { font-size: 0.8rem; color: var(--text-dim); display: flex; gap: 12px; }
        
        .workout-stats { text-align: right; }
        .volume-tag { color: #57ca22; font-weight: 700; font-size: 0.9rem; display: block; }
        .duration-text { font-size: 0.75rem; color: var(--text-dim); }

        .accordion-content {
            display: none;
            padding: 0 20px 20px;
            border-top: 1px solid #2a2a2a;
            background: rgba(0,0,0,0.1);
        }

        .accordion-header.active i.chevron { transform: rotate(180deg); }
        .chevron { transition: 0.3s; color: var(--text-dim); }

        .ex-summary-item { margin-top: 20px; }
        .ex-name { 
            color: #57ca22; font-size: 0.85rem; font-weight: 700; 
            text-transform: uppercase; margin-bottom: 10px; display: block;
        }

        .sets-table { width: 100%; display: flex; flex-direction: column; gap: 6px; }
        .set-row-history {
            display: grid;
            grid-template-columns: 40px 1fr 1fr;
            gap: 10px;
            align-items: center;
        }

        .set-cell {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            padding: 6px;
            text-align: center;
            font-size: 0.85rem;
            color: white;
            font-weight: 600;
        }
        .set-cell.no { color: #57ca22; }
    </style>
</head>
<body>

    <?php include 'includes/header.php'; ?>

    <main class="history-container">
        <h2 style="margin-bottom: 25px;">Historia Treningów</h2>

        <?php if (empty($history)): ?>
            <p style="color: var(--text-dim); text-align: center;">Nie znaleziono treningów.</p>
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
                    <i class="fa-solid fa-chevron-down chevron" style="margin-left: 15px;"></i>
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

    <script>
    function toggleAccordion(header) {
        header.classList.toggle('active');
        const content = header.nextElementSibling;
        
        if (content.style.display === "block") {
            content.style.display = "none";
        } else {
            content.style.display = "block";
        }
    }
    </script>
</body>
</html>