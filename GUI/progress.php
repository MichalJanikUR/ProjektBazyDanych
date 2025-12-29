<?php
include 'includes/auth.php';
include 'includes/db.php';
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Twój Progres</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/progress.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet">
</head>
<body>

    <?php include 'includes/header.php'; ?>

    <main class="app-content">
        <h2 class="section-title">Analityka Progresu</h2>

        <div class="stats-row-top">
            <div class="mini-card">
                <i class="fa-solid fa-fire-smoke"></i>
                <div class="mini-info">
                    <span class="mini-label">Streak</span>
                    <span class="mini-value">12 dni</span>
                </div>
            </div>
            <div class="mini-card">
                <i class="fa-solid fa-bolt"></i>
                <div class="mini-info">
                    <span class="mini-label">VPM (Intensywność)</span>
                    <span class="mini-value">145 kg/min</span>
                </div>
            </div>
        </div>

        <h3 class="sub-title">Sugestie Systemu</h3>
        <div class="alerts-container">
            <div class="ai-alert progression">
                <div class="alert-icon"><i class="fa-solid fa-arrow-trend-up"></i></div>
                <div class="alert-text">
                    <h4>Gotowy na progres!</h4>
                    <p>Wyciskanie na klatkę: Sugerowane zwiększenie ciężaru o <strong>+2.5 kg</strong> na następnej sesji.</p>
                </div>
            </div>

            <div class="ai-alert warning">
                <div class="alert-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <div class="alert-text">
                    <h4>Detektor zmęczenia</h4>
                    <p>Twoja siła spadła o 12% w ostatnim tygodniu. Rozważ dzień odpoczynku lub deload.</p>
                </div>
            </div>
        </div>

        <h3 class="sub-title">Twoje Rekordy (Estymowane 1RM)</h3>
        <div class="records-list">
            <div class="record-item">
                <div class="exercise-info">
                    <span class="ex-name">Wyciskanie Sztangi</span>
                    <span class="ex-volume">Objętość: 2,450 kg</span>
                </div>
                <div class="ex-max">
                    <small>1RM</small>
                    <span>95.5 kg</span>
                </div>
            </div>

            <div class="record-item">
                <div class="exercise-info">
                    <span class="ex-name">Przysiad ze Sztangą</span>
                    <span class="ex-volume">Objętość: 3,100 kg</span>
                </div>
                <div class="ex-max">
                    <small>1RM</small>
                    <span>120 kg</span>
                </div>
            </div>
        </div>

        <h3 class="sub-title">Balans Strukturalny</h3>
        <div class="balance-card">
            <div class="balance-item">
                <span>Klatka vs Plecy</span>
                <div class="balance-bar">
                    <div class="bar-fill" style="width: 85%;"></div>
                </div>
                <small>Brakuje 15% objętości na plecy</small>
            </div>
        </div>

    </main>

    <?php include 'includes/navbar.php'; ?>

</body>
</html>