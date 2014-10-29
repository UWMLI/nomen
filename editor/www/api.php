<?php

require_once '../include/db.php';

header('Content-Type: application/json');

if ($stmt = $mysqli->prepare("SELECT id, title, version, description FROM datasets")) {
  $stmt->execute();
  $stmt->store_result();

  $datasets = [];

  $stmt->bind_result($id, $title, $version, $description);
  while ($row = $stmt->fetch()) {
    $datasets[] = [
      'id' => DATASET_PREFIX . $id,
      'title' => $title,
      'version' => $version,
      'description' => $description,
      'url' => 'datasets/' . $id . '.zip',
    ];
  }

  echo json_encode($datasets);
}
