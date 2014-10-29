<?php

require_once 'db.php';

function get_datasets($mysqli) {
  if ($stmt = $mysqli->prepare("SELECT id, title, version
    FROM datasets
    WHERE user_id = ?")) {
    $stmt->bind_param('i', $_SESSION['user_id']);
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

function dataset_title($dataset_id, $mysqli) {
  if ($stmt = $mysqli->prepare("SELECT title
    FROM datasets
    WHERE id = ?
    AND user_id = ?")) {
    $stmt->bind_param('ii', $dataset_id, $_SESSION['user_id']);
    $stmt->execute();
    $stmt->store_result();
    $stmt->bind_result($title);
    $stmt->fetch();
    if ($stmt->num_rows == 1) {
      return $title;
    }
  }
  return '';
}

function publish_dataset($dataset_id, $title, $upload_id, $mysqli) {
  if ($dataset_id <= 0) {
    // New dataset
    if ($stmt = $mysqli->prepare("INSERT INTO datasets (user_id, title, version) VALUES (?, ?, ?)")) {
      $version = 1;
      $stmt->bind_param('isi', $_SESSION['user_id'], $title, $version);
      $stmt->execute();
      $new_id = $stmt->insert_id;
      // TODO
    }
  }
  else {
    // New version of existing dataset
    if ($stmt = $mysqli->prepare("UPDATE datasets
      SET title = ?, version = version + 1
      WHERE id = ?
      AND user_id = ?")) {
      $stmt->bind_param('sii', $title, $dataset_id, $_SESSION['user_id']);
      $stmt->execute();
      $stmt->store_result();
      // TODO
    }
  }
}
