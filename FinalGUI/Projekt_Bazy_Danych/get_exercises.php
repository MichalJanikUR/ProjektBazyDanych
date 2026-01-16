<?php
include 'includes/db.php';

header('Content-Type: application/json');

$muscle_group_name = $_GET['muscle'] ?? '';

if (empty($muscle_group_name)) {
    echo json_encode([]);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT * FROM public.get_exercises_by_muscle_group(:name)");
    $stmt->execute(['name' => $muscle_group_name]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode($results);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}