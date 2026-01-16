<?php
include 'includes/auth.php';
include 'includes/db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Wywołujemy procedurę za pomocą CALL
        $stmt = $pdo->prepare("CALL public.update_user_measurements(
            :u, :w, :h, :n, :wa, :c, :b, :t, :hi, :al, :g
        )");
        
        $stmt->execute([
            'u'  => (int)$_SESSION['user_id'],
            'w'  => (float)$_POST['weight'],
            'h'  => (float)$_POST['height'],
            'n'  => (float)$_POST['neck'],
            'wa' => (float)$_POST['waist'],
            'c'  => (float)$_POST['chest'],
            'b'  => (float)$_POST['biceps'],
            't'  => (float)$_POST['thighs'],
            'hi' => (float)$_POST['hips'],
            'al' => (float)$_POST['activity_level'],
            'g'  => $_POST['goal']
        ]);

        header("Location: diet.php?update=success");
        exit;

    } catch (PDOException $e) {
        die("Błąd procedury: " . $e->getMessage());
    }
}