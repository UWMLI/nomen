<?php

function get_datasets($user_id, $mysqli) {
  if ($stmt = $mysqli->prepare("SELECT id, title, version
    FROM datasets
    WHERE user_id = ?")) {
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $stmt->store_result();

    $datasets = [];

    $stmt->bind_result($id, $title, $version);
    while ($row = $stmt->fetch()) {
      $datasets[] = [
        'id' => $id,
        'title' => $title,
        'version' => $version,
      ];
    }

    return $datasets;
  }
  return [];
}
