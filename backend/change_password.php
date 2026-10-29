<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$dbname = "programm_abirflutter123456";
$username = "programm_kabir";
$password = "kabir58426";

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $input = file_get_contents("php://input");
    $data = json_decode($input);
    if (!$data) {
        $data = (object) $_POST;
    }

    $userId = isset($data->user_id) ? intval($data->user_id) : 0;
    $currentPassword = isset($data->current_password) ? trim($data->current_password) : '';
    $newPassword = isset($data->new_password) ? trim($data->new_password) : '';

    if ($userId <= 0 || empty($currentPassword) || empty($newPassword)) {
        echo json_encode(["success" => false, "message" => "All password fields are required."]);
        exit();
    }

    $stmt = $conn->prepare("SELECT password FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode(["success" => false, "message" => "User not found."]);
        exit();
    }

    $dbPassword = $user['password'];
    $isValid = false;

    if ($currentPassword === $dbPassword || password_verify($currentPassword, $dbPassword)) {
        $isValid = true;
    }

    if (!$isValid) {
        echo json_encode(["success" => false, "message" => "Incorrect current password."]);
        exit();
    }

    $updateStmt = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
    $updateStmt->execute([$newPassword, $userId]);

    echo json_encode([
        "success" => true,
        "message" => "Password changed successfully."
    ]);
    exit();

} catch (Throwable $e) {
    http_response_code(200);
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
    exit();
}
?>
