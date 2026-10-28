<?php
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
    // Check if email already exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => false, "message" => "Email already registered."]);
        exit();
    }

    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // Try inserting with address, if column doesn't exist, fallback to inserting without address
    try {
        $stmt = $conn->prepare("INSERT INTO users (name, email, address, password) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $email, $address, $hashedPassword]);
    } catch (PDOException $e) {
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

} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
