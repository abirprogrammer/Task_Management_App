<?php
include_once 'config.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->id) && !empty($data->user_id)) {
    $id = $data->id;
    $user_id = $data->user_id;

    $stmt = $conn->prepare("DELETE FROM tasks WHERE id = ? AND user_id = ?");
    if ($stmt->execute([$id, $user_id])) {
        echo json_encode(["success" => true, "message" => "Task deleted successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to delete task."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Task ID and User ID are required."]);
}
?>
