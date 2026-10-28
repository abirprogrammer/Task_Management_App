<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $host = "localhost";
    $dbname = "programm_abirflutter123456";
    $username = "programm_kabir";
    $password = "kabir58426";

    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $input = file_get_contents("php://input");
    $data = json_decode($input);
    if (!$data) {
        $data = (object) $_POST;
    }

    $email = isset($data->email) ? trim($data->email) : '';
    $otp = isset($data->otp) ? trim($data->otp) : '';

    if (empty($email) || empty($otp)) {
        echo json_encode(["success" => false, "message" => "Email and OTP are required."]);
        exit();
    }

    $conn->exec("CREATE TABLE IF NOT EXISTS otps (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(150) NOT NULL,
        otp VARCHAR(6) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");

    $stmt = $conn->prepare("SELECT * FROM otps WHERE email = ? ORDER BY id DESC LIMIT 1");
    $stmt->execute([$email]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($record && $record['otp'] === $otp) {
        $stmt = $conn->prepare("DELETE FROM otps WHERE email = ?");
        $stmt->execute([$email]);

        echo json_encode(["success" => true, "message" => "OTP verified successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid or expired verification code."]);
    }
} catch (Throwable $e) {
    http_response_code(200);
    echo json_encode([
        "success" => false,
        "message" => "PHP Error: " . $e->getMessage(),
        "file" => basename($e->getFile()),
        "line" => $e->getLine()
    ]);
}
?>
