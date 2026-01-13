<?php
session_start();
include 'includes/db.php';
$error_message = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_input = $_POST['username'];
    $pass_input = $_POST['password'];

    try {
        // Wywołujemy Twoją funkcję: public.login_by_username(username, password)
        // Funkcja zwraca tabelę (user_id, first_name) tylko jeśli dane są poprawne
        $stmt = $pdo->prepare("SELECT * FROM public.login_by_username(:username, :password)");
        $stmt->execute([
            'username' => $user_input,
            'password' => $pass_input
        ]);
        
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            // Logowanie udane - funkcja zwróciła dane
            $_SESSION['user_id'] = $user['user_id'];
            $_SESSION['first_name'] = $user['first_name'];
            $_SESSION['username'] = $user_input; // Login zachowujemy z posta
            
            header("Location: dashboard.php");
            exit();
        } else {
            // Funkcja nic nie zwróciła = błędne dane
            $error_message = "Nieprawidłowy login lub hasło.";
        }
    } catch (PDOException $e) {
        $error_message = "Błąd bazy danych: " . $e->getMessage();
    }
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AwareFit - Logowanie</title>
    <link rel="stylesheet" href="css/global.css">
    <link rel="icon" href="image/AwareFit-logo.png">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-box">
            <div class="logo-section">
                <img src="image/AwareFit-white.png" alt="AwareFit Logo" class="main-logo">
                <p>Twój inteligentny dziennik treningowy</p>
            </div>

            <?php if ($error_message): ?>
                <div class="error-msg" style="background: rgba(255,68,68,0.1); border: 1px solid #ff4444; border-radius: 12px; padding: 10px; margin-bottom: 20px; color: #ff4444; font-size: 0.85rem; text-align: center;">
                    <?php echo htmlspecialchars($error_message); ?>
                </div>
            <?php endif; ?>

            <form action="index.php" method="POST" class="login-form" autocomplete="off">
                
                <input type="text" style="display:none" aria-hidden="true">
                <input type="password" style="display:none" aria-hidden="true">

                <div class="input-group">
                    <label>Nazwa użytkownika</label>
                    <input type="text" name="username" placeholder="Wprowadź login" required autocomplete="none">
                </div>

                <div class="input-group">
                    <label>Hasło</label>
                    <input type="password" name="password" placeholder="Wprowadź hasło" required autocomplete="new-password">
                </div>

                <div class="form-options">
                    <label class="remember-me">
                        <input type="checkbox"> Zapamiętaj mnie
                    </label>
                </div>

                <button type="submit" class="login-btn">ZALOGUJ SIĘ</button>
            </form>

            <div class="login-footer">
                Nie masz konta? <a href="register.php">Zarejestruj się za darmo</a>
            </div>
        </div>
    </div>
</body>
</html>