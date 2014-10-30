<?php

require_once '../include/db.php';

header('Content-Type: application/json');

if ($stmt = $mysqli->prepare("SELECT d.id, d.title, d.version, d.description, u.email
  FROM datasets AS d
  INNER JOIN users AS u ON d.user_id = u.id")) {
  $stmt->execute();
  $stmt->store_result();

  $datasets = [];

  $stmt->bind_result($id, $title, $version, $description, $email);
  while ($row = $stmt->fetch()) {
    $datasets[] = [
      'id' => DATASET_PREFIX . $id,
      'title' => $title,
      'version' => $version,
      'description' => $description,
      'author' => $email,
      'url' => 'datasets/' . $id . '.zip',
    ];
  }

  echo json_encode($datasets);
}
