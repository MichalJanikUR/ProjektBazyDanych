<?php
include 'includes/auth.php';
include 'includes/db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['goal'])) {
    $new_goal = $_POST['goal'];
    $user_id = $_SESSION['user_id'];

    try {
        $stmt = $pdo->prepare("SELECT public.update_user_goal(:user_id::integer, :goal::text)");
        $stmt->execute([
            'goal' => $new_goal,
            'user_id' => $user_id
        ]);
        
        echo "Success";
    } catch (\PDOException $e) {
        error_log("Błąd aktualizacji celu: " . $e->getMessage());
        http_response_code(500);
        echo "Błąd bazy danych";
    }
}