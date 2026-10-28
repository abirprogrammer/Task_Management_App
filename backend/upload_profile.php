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

    $conn->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image LONGTEXT DEFAULT NULL");

    $input = file_get_contents("php://input");
    $data = json_decode($input);
    if (!$data) {
        $data = (object) $_POST;
    }

    $userId = isset($data->user_id) ? intval($data->user_id) : 0;
    $imageBase64 = isset($data->image_base64) ? trim($data->image_base64) : '';

    if ($userId <= 0 || empty($imageBase64)) {
        echo json_encode(["success" => false, "message" => "User ID and image data are required."]);
        exit();
    }

    $stmt = $conn->prepare("UPDATE users SET profile_image = ? WHERE id = ?");
    $stmt->execute([$imageBase64, $userId]);

    echo json_encode([
        "success" => true,
        "message" => "Profile image uploaded and updated successfully in users table."
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
