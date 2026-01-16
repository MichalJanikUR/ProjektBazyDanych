<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];

try {
    // Dodajemy first_name i last_name do SELECT
    $stmt = $pdo->prepare("SELECT username, email, gender, first_name, last_name FROM public.users WHERE id = :id");
    $stmt->execute(['id' => $user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
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
    <title>AwareFit - Twój Profil</title>
    <link rel="stylesheet" href="css/global.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/account.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet">
        <link rel="icon" href="image/AwareFit-logo.png">
</head>
<body>

    <?php include 'includes/header.php'; ?>

    <main class="app-content">
        <div class="profile-header">
            <div class="profile-avatar">
                <i class="fa-solid fa-circle-user"></i>
            </div>
            <h2 class="profile-username">
                <?php 
                    echo ($user['first_name'] || $user['last_name']) 
                        ? htmlspecialchars($user['first_name'] . ' ' . $user['last_name']) 
                        : htmlspecialchars($user['username']); 
                ?>
            </h2>
            <p class="profile-email"><?php echo htmlspecialchars($user['email']); ?></p>
        </div>

        <section class="profile-details">
            <div class="detail-item">
                <span class="detail-label">Imię</span>
                <span class="detail-value"><?php echo htmlspecialchars($user['first_name'] ?? 'Nie ustawiono'); ?></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Nazwisko</span>
                <span class="detail-value"><?php echo htmlspecialchars($user['last_name'] ?? 'Nie ustawiono'); ?></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Nazwa użytkownika</span>
                <span class="detail-value"><?php echo htmlspecialchars($user['username']); ?></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Płeć</span>
                <span class="detail-value"><?php echo ($user['gender'] == 'Male') ? 'Mężczyzna' : 'Kobieta'; ?></span>
            </div>
        </section>

        <section class="profile-actions">
            <a href="logout.php" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i> Wyloguj się
            </a>
        </section>
    </main>

    <?php include 'includes/navbar.php'; ?>

</body>
</html>