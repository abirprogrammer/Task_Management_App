<?php
include_once 'config.php';

$input = file_get_contents("php://input");
$data = json_decode($input);

is_object($data) or $data = (object) $_POST;

$email = isset($data->email) ? trim($data->email) : '';
$password = isset($data->password) ? $data->password : '';

if (empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Incomplete data provided. Email and password are required."]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($password, $user['password'])) {
        echo json_encode([
            "success" => true,
            "message" => "Login successful.",
            "user" => [
                "id" => (int) $user['id'],
                "name" => $user['name'],
                "email" => $user['email'],
                "address" => isset($user['address']) ? $user['address'] : ''
            ]
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid email or password."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
