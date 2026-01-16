<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // 1. Pobranie najnowszych pomiarów ciała
    $stmt = $pdo->prepare("SELECT * FROM public.body_measurements WHERE user_id = :user_id ORDER BY date DESC LIMIT 1");
    $stmt->execute(['user_id' => $user_id]);
    $m = $stmt->fetch(PDO::FETCH_ASSOC);

    // 2. Pobranie makroskładników Z FUNKCJI SQL (To jest kluczowe)
    $stmt_macro = $pdo->prepare("SELECT * FROM public.get_user_macros(:user_id)");
    $stmt_macro->execute(['user_id' => $user_id]);
    $macro = $stmt_macro->fetch(PDO::FETCH_ASSOC);

    // 3. Pobranie celu i opisu diety (do etykiety celu)
    $stmt_diet = $pdo->prepare("SELECT * FROM public.calculate_user_diet_calories(:user_id)");
    $stmt_diet->execute(['user_id' => $user_id]);
    $diet = $stmt_diet->fetch(PDO::FETCH_ASSOC);

    // 4. Pobranie % BF
    $stmt_bf = $pdo->prepare("SELECT public.calculate_user_bf(:user_id)");
    $stmt_bf->execute(['user_id' => $user_id]);
    $body_fat = $stmt_bf->fetchColumn();

} catch (PDOException $e) {
    echo "Błąd: " . $e->getMessage();
    exit;
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Dieta i Pomiary</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/diet.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="image/AwareFit-logo.png">
</head>
<body class="diet-body">

    <?php include 'includes/header.php'; ?>

    <main class="app-content">

        <?php if ($m): ?>

            <section class="bf-highlight-card">
                <div class="bf-info">
                    <span class="bf-label">Poziom tkanki tłuszczowej</span>
                    <span class="bf-value"><?php echo $body_fat ? $body_fat . '%' : '--'; ?></span>
                    <p class="bf-desc">Metoda US Navy</p>
                </div>
                <div class="bf-icon"><i class="fa-solid fa-droplet"></i></div>
            </section>

            <section class="diet-summary-card">
    <div class="diet-info">
        <span class="diet-label">Zalecane spożycie (<?php echo htmlspecialchars($diet['goal_label'] ?? 'Cel'); ?>)</span>
        <h2 class="diet-kcal">
            <?php echo $macro['calories_total'] ?? '0'; ?> 
            <small>kcal</small>
        </h2>
    </div>
    <div class="diet-macros-mini">
        <div class="mini-macro">
            <span class="macro-name">Białko</span>
            <strong><?php echo $macro['protein_g'] ?? '0'; ?>g</strong>
        </div>
        <div class="mini-macro">
            <span class="macro-name">Tłuszcze</span>
            <strong><?php echo $macro['fat_g'] ?? '0'; ?>g</strong>
        </div>
        <div class="mini-macro">
            <span class="macro-name">Węgle</span>
            <strong><?php echo $macro['carbs_g'] ?? '0'; ?>g</strong>
        </div>
    </div>
</section>

        <div class="section-header">
            <h3 class="section-title">Twoje Pomiary</h3>
            <span class="section-badge">Ostatnia aktualizacja</span>
        </div>

            <section class="measurements-grid compact">
                <div class="m-card">
                    <span class="m-label">Waga</span>
                    <span class="m-val"><?php echo $m['weight']; ?> <small>kg</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Wzrost</span>
                    <span class="m-val"><?php echo $m['height']; ?> <small>cm</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Pas</span>
                    <span class="m-val"><?php echo $m['waist']; ?> <small>cm</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Szyja</span>
                    <span class="m-val"><?php echo $m['neck']; ?> <small>cm</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Klatka</span>
                    <span class="m-val"><?php echo $m['chest']; ?> <small>cm</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Biceps</span>
                    <span class="m-val"><?php echo $m['biceps']; ?> <small>cm</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Udo</span>
                    <span class="m-val"><?php echo $m['thighs']; ?> <small>cm</small></span>
                </div>
                <div class="m-card">
                    <span class="m-label">Biodra</span>
                    <span class="m-val"><?php echo $m['hips']; ?> <small>cm</small></span>
                </div>
            </section>

            <p class="last-update">Aktualizacja: <?php echo date('d.m.Y', strtotime($m['date'])); ?></p>

            <div class="action-container">
            <button class="main-cta-btn" onclick="toggleMeasurementModal()">
    <i class="fa-solid fa-plus"></i> NOWY POMIAR I CEL
</button>
        </div>

<?php else: ?>
    <div class="no-data" style="text-align: center; padding: 40px 20px;">
        <i class="fa-solid fa-utensils" style="font-size: 3rem; color: var(--text-dim); opacity: 0.3; margin-bottom: 20px; display: block;"></i>
        <p style="color: var(--text-dim); margin-bottom: 25px;">Brak danych. Dodaj swój pierwszy pomiar, aby obliczyć dietę.</p>
        
        <button class="main-cta-btn" onclick="toggleMeasurementModal()">
            <i class="fa-solid fa-plus"></i> DODAJ POMIAR I CEL
        </button>
    </div>
<?php endif; ?>

    </main>

    <?php include 'includes/navbar.php'; ?>

<div id="measurementModal" class="modal-overlay">
    <div class="modal-card">
        <div class="modal-header">
            <h3><i class="fa-solid fa- gauge-high"></i> Nowy Pomiar</h3>
            <button type="button" class="close-btn" onclick="toggleMeasurementModal()">&times;</button>
        </div>
        
        <form id="measurementForm" action="add_measurement_action.php" method="POST">
            <div class="measurements-input-grid">
                <div class="input-group">
                    <label>Waga (kg)</label>
                    <input type="number" step="0.1" name="weight" placeholder="<?php echo $m['weight'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Wzrost (cm)</label>
                    <input type="number" step="0.1" name="height" placeholder="<?php echo $m['height'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Szyja (cm)</label>
                    <input type="number" step="0.1" name="neck" placeholder="<?php echo $m['neck'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Pas (cm)</label>
                    <input type="number" step="0.1" name="waist" placeholder="<?php echo $m['waist'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Klatka</label>
                    <input type="number" step="0.1" name="chest" placeholder="<?php echo $m['chest'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Biceps</label>
                    <input type="number" step="0.1" name="biceps" placeholder="<?php echo $m['biceps'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Biodra</label>
                    <input type="number" step="0.1" name="hips" placeholder="<?php echo $m['hips'] ?? '0'; ?>" required>
                </div>
                <div class="input-group">
                    <label>Udo</label>
                    <input type="number" step="0.1" name="thighs" placeholder="<?php echo $m['thighs'] ?? '0'; ?>" required>
                </div>
            </div>

            <hr class="modal-divider">

            <div class="strategy-section">
                <div class="input-group full">
                    <label><i class="fa-solid fa-person-walking"></i> Aktywność</label>
                    <select name="activity_level" required>
    <option value="1.2">Brak (Siedzący tryb)</option>
    <option value="1.375">Lekka (1-2 treningi)</option>
    <option value="1.55">Średnia (3-4 treningi)</option>
    <option value="1.725">Wysoka (5+ treningów)</option>
</select>
                </div>

                <div class="input-group full">
                    <label><i class="fa-solid fa-bullseye"></i> Cel sylwetkowy</label>
                    <select name="goal" required>
                        <option value="Zbudowanie masy mięśniowej" <?php echo (($m['goal'] ?? '') == 'Zbudowanie masy mięśniowej') ? 'selected' : ''; ?>>Masa (+10% kcal)</option>
                        <option value="Rekompozycja ciała" <?php echo (($m['goal'] ?? '') == 'Rekompozycja ciała') ? 'selected' : ''; ?>>Rekompozycja</option>
                        <option value="Redukcja tkanki tłuszczowej" <?php echo (($m['goal'] ?? '') == 'Redukcja tkanki tłuszczowej') ? 'selected' : ''; ?>>Redukcja (-20% kcal)</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="modal-submit-btn">DODAJ POMIAR I AKTUALIZUJ CEL</button>
        </form>
    </div>
</div>
<script src="js/add_measurements.js?v=<?php echo time(); ?>"></script>

</body>
</html>