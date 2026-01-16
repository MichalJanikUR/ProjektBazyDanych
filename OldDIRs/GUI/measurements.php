<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // Pobranie najnowszych pomiarów
    $stmt = $pdo->prepare("SELECT * FROM public.body_measurements WHERE user_id = :user_id ORDER BY date DESC LIMIT 1");
    $stmt->execute(['user_id' => $user_id]);
    $m = $stmt->fetch(PDO::FETCH_ASSOC);

    // Pobranie obliczonego % BF z Twojej funkcji PGSQL
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
    <title>AwareFit - Pomiary</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/measurements.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet">
        <link rel="icon" href="image/AwareFit-logo.png">
</head>
<body>

    <?php include 'includes/header.php'; ?>

    <main class="app-content">

        <?php if ($m): ?>
            <section class="bf-highlight-card">
                <div class="bf-info">
                    <span class="bf-label">Szacowany % tkanki tłuszczowej</span>
                    <span class="bf-value"><?php echo $body_fat ? $body_fat . '%' : '--'; ?></span>
                    <p class="bf-desc">Metoda US Navy (na podstawie obwodów)</p>
                </div>
                <div class="bf-icon">
                    <i class="fa-solid fa-droplet"></i>
                </div>
            </section>

            <section class="measurements-grid">
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
                    <span class="m-label">Klatka piersiowa</span>
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

        <?php else: ?>
            <div class="no-data">
                <i class="fa-solid fa-ruler"></i>
                <p>Brak zapisanych pomiarów.</p>
                <button class="main-cta-btn">DODAJ PIERWSZY POMIAR</button>
            </div>
        <?php endif; ?>

        <div class="action-container">
            <button class="main-cta-btn" onclick="window.location.href='add_measurement.php'">
                <i class="fa-solid fa-plus"></i> DODAJ POMIAR
            </button>
        </div>

                    <p class="last-update">Ostatnia aktualizacja: <?php echo date('d.m.Y', strtotime($m['date'])); ?></p>


    </main>

    <?php include 'includes/navbar.php'; ?>

</body>
</html>