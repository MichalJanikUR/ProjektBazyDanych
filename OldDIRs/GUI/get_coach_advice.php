<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];
$exercise_id = $_GET['exercise_id'] ?? null;

if (!$exercise_id) {
    echo json_encode(['status' => 'ERROR']);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT public.get_exercise_progression_status(?, ?)");
    $stmt->execute([$user_id, $exercise_id]);
    $status = $stmt->fetchColumn();

    echo json_encode(['status' => $status]);
} catch (Exception $e) {
    echo json_encode(['status' => 'ERROR']);
}