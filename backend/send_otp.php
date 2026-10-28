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

    if (empty($email)) {
        echo json_encode(["success" => false, "message" => "Email is required."]);
        exit();
    }

    $otp = sprintf("%06d", mt_rand(1, 999999));

    // Ensure otps table exists
    $conn->exec("CREATE TABLE IF NOT EXISTS otps (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(150) NOT NULL,
        otp VARCHAR(6) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");

    $stmt = $conn->prepare("DELETE FROM otps WHERE email = ?");
    $stmt->execute([$email]);

    $stmt = $conn->prepare("INSERT INTO otps (email, otp) VALUES (?, ?)");
    $stmt->execute([$email, $otp]);

    // Attempt mail safely
    try {
        $subject = "TaskMaster Pro - Verification Code";
        $message = "Your verification code is: " . $otp;
        $headers = "From: noreply@programmingpulse.xyz\r\n";
        @mail($email, $subject, $message, $headers);
    } catch (Throwable $mailEx) {
        // Suppress mail error
    }

    echo json_encode([
        "success" => true,
        "message" => "OTP generated successfully.",
        "debug_otp" => $otp
    ]);
    exit();

} catch (Throwable $e) {
    http_response_code(200);
    echo json_encode([
        "success" => false,
        "message" => "Server Exception: " . $e->getMessage(),
        "file" => basename($e->getFile()),
        "line" => $e->getLine()
    ]);
    exit();
}
?>
