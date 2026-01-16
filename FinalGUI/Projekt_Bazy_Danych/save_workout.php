<?php
include 'includes/auth.php';
include 'includes/db.php';

header('Content-Type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data || !isset($data['workout'])) {
    echo json_encode(['success' => false, 'message' => 'Brak poprawnych danych treningu']);
    exit;
}

$user_id = $_SESSION['user_id'];
$duration = $data['duration'] ?? 0;

$workout_json = json_encode($data['workout']);

try {
    $stmt = $pdo->prepare("SELECT public.save_complete_workout(:u::integer, :d::integer, :w::jsonb)");
    $stmt->execute([
        'u' => $user_id,
        'd' => $duration,
        'w' => $workout_json
    ]);
    
    echo json_encode(['success' => true]);
} catch (\PDOException $e) {
    error_log("Błąd zapisu treningu: " . $e->getMessage());
    echo json_encode([
        'success' => false, 
        'message' => 'Wystąpił błąd po stronie bazy danych.'
    ]);
}