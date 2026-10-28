<?php
include_once 'config.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->id) && !empty($data->user_id)) {
    $id = $data->id;
    $user_id = $data->user_id;
    $title = isset($data->title) ? trim($data->title) : "";
    $description = isset($data->description) ? trim($data->description) : "";
    $category = isset($data->category) ? trim($data->category) : "Work";
    $due_date = isset($data->due_date) ? trim($data->due_date) : "";
    $priority = isset($data->priority) ? trim($data->priority) : "Medium";
    $is_completed = isset($data->is_completed) ? (int)$data->is_completed : 0;

    $stmt = $conn->prepare("UPDATE tasks SET title = ?, description = ?, category = ?, due_date = ?, priority = ?, is_completed = ? WHERE id = ? AND user_id = ?");
    if ($stmt->execute([$title, $description, $category, $due_date, $priority, $is_completed, $id, $user_id])) {
        echo json_encode(["success" => true, "message" => "Task updated successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to update task."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Task ID and User ID are required."]);
}
?>
