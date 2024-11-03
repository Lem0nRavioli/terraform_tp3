<?php
$servername = "data";
$username = "root";
$password = "rootpassword";
$dbname = "testdb";

try {
    // Connexion à la base de données avec PDO
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    // Configuration des attributs PDO pour afficher les erreurs
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Création d'une table si elle n'existe pas déjà
    $conn->exec("CREATE TABLE IF NOT EXISTS test_table (
        id INT AUTO_INCREMENT PRIMARY KEY,
        content VARCHAR(255) NOT NULL
    )");

    // Insertion de données
    $conn->exec("INSERT INTO test_table (content) VALUES ('Hello, World!')");

    // Lecture de la dernière entrée
    $stmt = $conn->query("SELECT content FROM test_table ORDER BY id DESC LIMIT 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        echo "Dernière entrée : " . $row["content"];
    } else {
        echo "Aucune donnée disponible.";
    }
} catch (PDOException $e) {
    echo "Erreur de connexion : " . $e->getMessage();
}

// Fermeture de la connexion
$conn = null;
?>