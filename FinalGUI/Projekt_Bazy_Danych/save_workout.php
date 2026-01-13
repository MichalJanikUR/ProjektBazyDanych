<?php
include 'includes/auth.php';
include 'includes/db.php';

header('Content-Type: application/json');

// Odbieramy surowe dane JSON
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data || !isset($data['workout'])) {
    echo json_encode(['success' => false, 'message' => 'Brak danych']);
    exit;
}

$user_id = $_SESSION['user_id'];
$duration = $data['duration'] ?? 0;
// Przekazujemy listę ćwiczeń jako string JSON dla PostgreSQL
$workout_json = json_encode($data['workout']);

try {
    $stmt = $pdo->prepare("SELECT public.save_complete_workout(?, ?, ?)");
    $stmt->execute([$user_id, $duration, $workout_json]);
    
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Błąd bazy: ' . $e->getMessage()]);
}