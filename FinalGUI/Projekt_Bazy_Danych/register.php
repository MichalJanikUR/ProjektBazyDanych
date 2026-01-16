<?php
include 'includes/db.php'; 
$message = "";
$message_type = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Odbieranie danych z formularza
    $u  = $_POST['username'] ?? '';
    $p  = $_POST['password'] ?? '';
    $e  = $_POST['email'] ?? '';
    $fn = $_POST['first_name'] ?? '';
    $ln = $_POST['last_name'] ?? '';
    $g  = $_POST['gender'] ?? ''; 

    try {
        $stmt = $pdo->prepare("CALL crud.insert_user(
            :u::text, 
            :p::text, 
            :e::text, 
            :fn::text, 
            :ln::text, 
            :g::text
        )");
        
        $stmt->execute([
            'u'  => $u,
            'p'  => $p,
            'e'  => $e,
            'fn' => $fn,
            'ln' => $ln,
            'g'  => $g
        ]); 

        $message = "Konto zostało utworzone pomyślnie! Możesz się teraz zalogować.";
        $message_type = "success";
        
    } catch (\PDOException $ex) {
        $raw_error = $ex->getMessage();
        
        if (strpos($raw_error, 'już istnieje') !== false) {
            $message = "Wybrana nazwa użytkownika jest już zajęta.";
        } elseif (strpos($raw_error, 'już zajęty') !== false) {
            $message = "Podany adres e-mail jest już przypisany do innego konta.";
        } elseif (strpos($raw_error, 'format email') !== false) {
            $message = "Wprowadzony adres e-mail ma niepoprawny format.";
        } else {
            error_log("Błąd rejestracji: " . $raw_error);
            $message = "Wystąpił błąd podczas rejestracji. Spróbuj ponownie później.";
        }
        $message_type = "error";
    }
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Rejestracja</title>
    <link rel="stylesheet" href="css/global.css">
    <link rel="icon" href="image/AwareFit-logo.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-box">
            <div class="logo-section">
                <img src="image/AwareFit-white.png" alt="AwareFit Logo" class="main-logo">
                <p>Dołącz do społeczności AwareFit</p>
            </div>

            <?php if ($message): ?>
                <div class="message-box" 
                     style="margin-bottom: 20px; padding: 12px; border-radius: 12px; border: 1px solid <?php echo $message_type == 'error' ? '#ff4444' : '#4CAF50'; ?>; color: <?php echo $message_type == 'error' ? '#ff4444' : '#4CAF50'; ?>; background: <?php echo $message_type == 'error' ? 'rgba(255,68,68,0.1)' : 'rgba(76,175,80,0.1)'; ?>; font-size: 0.85rem; text-align: center;">
                    <?php echo htmlspecialchars($message); ?>
                </div>
            <?php endif; ?>

            <form action="register.php" method="POST" class="login-form" autocomplete="off">
                <input type="text" style="display:none" aria-hidden="true">
                <input type="password" style="display:none" aria-hidden="true">

                <div class="input-group">
                    <label>Nazwa użytkownika</label>
                    <input type="text" name="username" placeholder="Wprowadź login" required>
                </div>

                <div class="input-group">
                    <label>Adres E-mail</label>
                    <input type="email" name="email" placeholder="twoj@email.com" required>
                </div>

                <div class="input-group">
                    <label>Imię</label>
                    <input type="text" name="first_name" placeholder="Wprowadź imię" required>
                </div>

                <div class="input-group">
                    <label>Nazwisko</label>
                    <input type="text" name="last_name" placeholder="Wprowadź nazwisko" required>
                </div>

                <div class="input-group">
    <label for="gender">Płeć</label>
    <select name="gender" id="gender" required style="width: 100%; padding: 18px 22px; background: #2a2b2d; border: 1px solid #3a3b3d; border-radius: 18px; color: white;">
        <option value="" disabled selected>Wybierz płeć</option>
        <option value="Male">Mężczyzna</option>
        <option value="Female">Kobieta</option>
    </select>
</div>

                <div class="input-group">
                    <label>Hasło</label>
                    <input type="password" name="password" placeholder="Wprowadź hasło" required autocomplete="new-password">
                </div>

                <button type="submit" class="login-btn">STWÓRZ KONTO</button>
            </form>

            <div class="login-footer">
                Masz już konto? <a href="index.php">Zaloguj się</a>
            </div>
        </div>
    </div>
</body>
</html>