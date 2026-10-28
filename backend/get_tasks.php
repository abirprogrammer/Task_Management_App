<?php
include_once 'config.php';

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : (isset($_POST['user_id']) ? $_POST['user_id'] : null);

if (!$user_id) {
    $data = json_decode(file_get_contents("php://input"));
    if (isset($data->user_id)) {
        $user_id = $data->user_id;
    }
}

if ($user_id) {
    $stmt = $conn->prepare("SELECT * FROM tasks WHERE user_id = ? ORDER BY id DESC");
    $stmt->execute([$user_id]);
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Convert is_completed to boolean int / bool for json
    foreach ($tasks as &$task) {
        $task['is_completed'] = (int)$task['is_completed'];
    }

    echo json_encode([
        "success" => true,
        "tasks" => $tasks
    ]);
} else {
    echo json_encode(["success" => false, "message" => "User ID is required."]);
}
?>
