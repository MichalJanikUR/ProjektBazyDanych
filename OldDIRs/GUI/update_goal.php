<?php
include 'includes/auth.php';
include 'includes/db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['goal'])) {
    $new_goal = $_POST['goal'];
    $user_id = $_SESSION['user_id'];

    try {
        // Aktualizujemy kolumnę 'goal' w tabeli 'users'
        $stmt = $pdo->prepare("UPDATE public.users SET goal = :goal WHERE id = :user_id");
        $stmt->execute([
            'goal' => $new_goal,
            'user_id' => $user_id
        ]);
        
        echo "Success";
    } catch (PDOException $e) {
        http_response_code(500);
        echo "Błąd bazy: " . $e->getMessage();
    }
}