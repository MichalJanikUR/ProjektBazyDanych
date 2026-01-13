<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Sesja treningowa</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/dashboard.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/workout.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="image/AwareFit-logo.png">

</head>
<script>
    const currentUserId = <?php echo json_encode($_SESSION['user_id']); ?>;
</script>
<body class="dashboard-body">

    <?php include 'includes/header.php'; ?>

    <main class="app-content">
        <div class="workout-session-header" style="text-align: center; margin-bottom: 30px;">
            <h2 style="font-size: 1.5rem; color: white;">Aktywna Sesja</h2>
            <div id="workout-timer" style="color: var(--accent-color); font-weight: 700; font-size: 1.2rem;">00:00:00</div>
        </div>

        <div class="workout-main-wrapper">
            
            <div id="step-workout-session" class="workout-step active">
    <div id="active-workout-log">
        <p style="color: var(--text-dim);">Brak ćwiczeń w tej sesji.</p>
    </div>
    
    <button class="btn-basic" onclick="showStep('muscle-groups')">
        <i class="fa-solid fa-plus"></i> DODAJ ĆWICZENIE
    </button>

    <button onclick="finishWorkout()" class="btn-finish" style="margin-top: 20px;">
        ZAKOŃCZ I ZAPISZ TRENING
    </button>

    <button onclick="cancelWorkout()" class="btn-cancel-session">
        <i class="fa-solid fa-trash-can"></i> Porzuć ten trening i zresetuj czas
    </button>
</div>

            <div id="step-muscle-groups" class="workout-step" style="display:none;">
                <button class="back-btn" onclick="showStep('workout-session')">
                    <i class="fa-solid fa-arrow-left"></i> Powrót do sesji
                </button>
                <div class="muscle-grid">
                    <?php
                    $stmt_mg = $pdo->query("SELECT * FROM crud.get_all_muscle_groups()");
                    while ($mg = $stmt_mg->fetch(PDO::FETCH_ASSOC)): 
                        $name = mb_strtolower($mg['name'], 'UTF-8');
                        $imagePath = 'image/default.png';
                        if (strpos($name, 'klatka') !== false) $imagePath = 'image/chest.png';
                        elseif (strpos($name, 'plecy') !== false) $imagePath = 'image/back.png';
                        elseif (strpos($name, 'bark') !== false) $imagePath = 'image/shoulders.png';
                        elseif (strpos($name, 'triceps') !== false) $imagePath = 'image/triceps.png';
                        elseif (strpos($name, 'biceps') !== false) $imagePath = 'image/biceps.png';
                        elseif (strpos($name, 'uda') !== false) $imagePath = 'image/thighs.png';
                        elseif (strpos($name, 'brzuch') !== false) $imagePath = 'image/abs.png';
                        elseif (strpos($name, 'łydk') !== false) $imagePath = 'image/calves.png';
                    ?>
                        <div class="muscle-card" onclick="selectMuscleGroup('<?php echo htmlspecialchars($mg['name']); ?>')">
                            <div class="muscle-image-container">
                                <img src="<?php echo $imagePath; ?>" class="muscle-icon-img">
                            </div>
                            <span><?php echo htmlspecialchars($mg['name']); ?></span>
                        </div>
                    <?php endwhile; ?>
                </div>
            </div>

            <div id="step-exercises" class="workout-step" style="display:none;">
                <button class="back-btn" onclick="showStep('muscle-groups')">
                    <i class="fa-solid fa-arrow-left"></i> Powrót do partii
                </button>
                <h3 id="selected-muscle-label" style="text-align:center; margin-bottom:15px; color:var(--accent-color);"></h3>
                <div id="exercise-list" class="list-container"></div>
            </div>

            <div id="step-log-set" class="workout-step" style="display:none;">
                <button class="back-btn" onclick="showStep('exercises')">
                    <i class="fa-solid fa-arrow-left"></i> Powrót do listy
                </button>
                
                <h3 id="selected-exercise-label" style="text-align:center; color:white; margin-bottom: 5px;"></h3>
                <p id="set-counter" style="text-align:center; color:var(--accent-color); font-weight: bold; margin-bottom: 15px;">Seria #1</p>

                        <h3 id="selected-exercise-label" style="text-align:center; color:white; margin-bottom: 5px;"></h3>

<div id="coach-advice-container" style="margin: 15px 0; display: none;">
    <div id="coach-bubble" style="background: rgba(87, 202, 34, 0.1); border: 1px solid var(--accent-color); border-radius: 15px; padding: 12px; display: flex; align-items: center; gap: 12px;">
        <i class="fa-solid fa-robot" style="color: var(--accent-color); font-size: 1.2rem;"></i>
        <p id="coach-text" style="color: white; font-size: 0.85rem; margin: 0; line-height: 1.4;"></p>
    </div>
</div>

<p id="set-counter" style="text-align:center; color:var(--accent-color); font-weight: bold; margin-bottom: 15px;">Seria #1</p>

                <form id="logSetForm">
                    <input type="hidden" id="exercise-id-input" name="exercise_id">
                    <div class="input-row">
                        <div class="input-group">
                            <label>Ciężar (KG)</label>
                            <input type="number" step="0.5" id="input-weight" name="weight" placeholder="0" required>
                        </div>
                        <div class="input-group">
                            <label>Powtórzenia</label>
                            <input type="number" id="input-reps" name="reps" placeholder="0" required>
                        </div>
                    </div>
                    
                    <button type="submit" id="add-set-btn" class="btn-basic" style="margin-bottom: 12px; border-color: var(--accent-color);">
                        <i class="fa-solid fa-plus"></i> DODAJ SERIĘ
                    </button>
                    
                    <button type="button" onclick="showStep('workout-session')" class="btn-finish btn-finish-alt">
                        ZAKOŃCZ ĆWICZENIE
                    </button>
                </form>

                <div id="current-exercise-sets" style="margin-top: 25px; width: 100%;">
                    </div>
            </div>

        </div>
    </main>

    <?php include 'includes/navbar.php'; ?>
    
    <script src="js/workout.js?v=<?php echo time(); ?>"></script>
</body>
</html>