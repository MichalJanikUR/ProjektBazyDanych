<?php
include 'includes/auth.php';
include 'includes/db.php';

$user_id = $_SESSION['user_id'];
$ex_id = $_GET['exercise_id'] ?? 0;
$set_no = $_GET['set_no'] ?? 1; // Odbieramy numer serii

$stmt = $pdo->prepare("SELECT * FROM public.get_last_exercise_stats(?, ?, ?)");
$stmt->execute([$user_id, $ex_id, $set_no]);
$stats = $stmt->fetch(PDO::FETCH_ASSOC);

echo json_encode($stats ?: ['last_weight' => 0, 'last_reps' => 0]);