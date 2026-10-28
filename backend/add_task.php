<?php
include_once 'config.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->user_id) && !empty($data->title)) {
    $user_id = $data->user_id;
    $title = trim($data->title);
    $description = isset($data->description) ? trim($data->description) : "";
    $category = isset($data->category) ? trim($data->category) : "Work";
    $due_date = isset($data->due_date) ? trim($data->due_date) : "";
    $priority = isset($data->priority) ? trim($data->priority) : "Medium";

    $stmt = $conn->prepare("INSERT INTO tasks (user_id, title, description, category, due_date, priority, is_completed) VALUES (?, ?, ?, ?, ?, ?, 0)");
    if ($stmt->execute([$user_id, $title, $description, $category, $due_date, $priority])) {
        $taskId = $conn->lastInsertId();
        echo json_encode([
            "success" => true,
            "message" => "Task added successfully.",
            "task_id" => $taskId
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to add task."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "User ID and title are required."]);
}
?>
