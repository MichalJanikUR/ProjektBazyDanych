<?php
include 'includes/auth.php';
include 'includes/db.php';

header('Content-Type: application/json');

$user_id = (int)$_SESSION['user_id'];
$ex_id   = (int)($_GET['exercise_id'] ?? 0);
$set_no  = (int)($_GET['set_no'] ?? 1);

try {
    $stmt = $pdo->prepare("SELECT * FROM public.get_last_exercise_stats(:u::integer, :e::integer, :s::integer)");
    $stmt->execute([
        'u' => $user_id,
        'e' => $ex_id,
        's' => $set_no
    ]);
    
    $stats = $stmt->fetch(\PDO::FETCH_ASSOC);

    // Zwrócenie wyniku lub domyślnie 0
    echo json_encode($stats ?: ['last_weight' => 0, 'last_reps' => 0]);

} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Błąd bazy danych']);
}