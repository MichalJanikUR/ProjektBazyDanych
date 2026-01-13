<?php
include 'includes/auth.php';
include 'includes/db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $user_id = (int)$_SESSION['user_id'];
        
        $sql = "CALL crud.insert_body_measurement(
            :u::integer, 
            NOW()::timestamp without time zone, 
            :h::double precision, 
            :w::double precision, 
            :c::double precision, 
            :wa::double precision, 
            :b::double precision, 
            :t::double precision, 
            :hi::double precision, 
            :n::numeric, 
            :g::character varying, 
            :al::numeric
        )";

        $stmt = $pdo->prepare($sql);
        
        $stmt->execute([
            'u'  => $user_id,
            'h'  => $_POST['height'],
            'w'  => $_POST['weight'],
            'c'  => $_POST['chest'],
            'wa' => $_POST['waist'],
            'b'  => $_POST['biceps'],
            't'  => $_POST['thighs'],
            'hi' => $_POST['hips'],
            'n'  => $_POST['neck'],
            'g'  => $_POST['goal'],
            'al' => $_POST['activity_level']
        ]);

        header("Location: diet.php?update=success");
        exit;

    } catch (PDOException $e) {
        // Wyświetlenie błędu pomoże nam zdiagnozować, jeśli baza odrzuci dane (np. walidacja)
        die("Błąd zapisu pomiarów: " . $e->getMessage());
    }
}