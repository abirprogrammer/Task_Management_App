<?php
error_reporting(0);
ini_set('display_errors', 0);

include_once 'config.php';

$input = file_get_contents("php://input");
$data = json_decode($input);

if (!$data) {
    $data = (object) $_POST;
}

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

    if ($user) {
        $storedPassword = $user['password'];
        $isValid = false;

        if (password_verify($password, $storedPassword) || $password === $storedPassword) {
            $isValid = true;
        }

        if ($isValid) {
            echo json_encode([
                "success" => true,
                "message" => "Login successful.",
                "user" => [
                    "id" => (int) $user['id'],
                    "name" => isset($user['name']) ? $user['name'] : 'User',
                    "email" => $user['email'],
                    "address" => isset($user['address']) ? $user['address'] : '',
                    "profile_image" => isset($user['profile_image']) ? $user['profile_image'] : null
                ]
            ]);
            exit();
        }
    }

    echo json_encode(["success" => false, "message" => "Invalid email or password."]);
    exit();

} catch (Throwable $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
    exit();
}
?>
