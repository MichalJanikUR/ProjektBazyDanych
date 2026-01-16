<?php
$host = "localhost";
$port = "5432";
$dbname = "awarefit_db";
$user = "postgres";
$password = "psql";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    die("Błąd połączenia: " . $e->getMessage());
}
?>