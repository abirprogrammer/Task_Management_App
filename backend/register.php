<?php
error_reporting(0);
ini_set('display_errors', 0);

include_once 'config.php';

$input = file_get_contents("php://input");
$data = json_decode($input);

if (!$data) {
    $data = (object) $_POST;
}

$name = isset($data->name) ? trim($data->name) : '';
$email = isset($data->email) ? trim($data->email) : '';
$address = isset($data->address) ? trim($data->address) : '';
$password = isset($data->password) ? $data->password : '';

if (empty($name) || empty($email) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Incomplete data provided. Name, email and password are required."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => false, "message" => "Email already registered."]);
        exit();
    }

    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    try {
        $stmt = $conn->prepare("INSERT INTO users (name, email, address, password) WHERE COLUMN_NAME IN (...) VALUES (?, ?, ?, ?)");
        // Just standard insert with address
        $stmt = $conn->prepare("INSERT INTO users (name, email, address, password) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $email, $address, $hashedPassword]);
    } catch (Throwable $e) {
        $stmt = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
        $stmt->execute([$name, $email, $hashedPassword]);
    }

    $userId = $conn->lastInsertId();
    echo json_encode([
        "success" => true,
        "message" => "User registered successfully.",
        "user" => [
            "id" => (int) $userId,
            "name" => $name,
            "email" => $email,
            "address" => $address
        ]
    ]);
    exit();

} catch (Throwable $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
    exit();
}
?>
