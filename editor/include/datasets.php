<?php

require_once 'db.php';

function get_datasets($mysqli) {
  if ($stmt = $mysqli->prepare("SELECT id, title, description, version
    FROM datasets
    WHERE user_id = ?")) {
    $stmt->bind_param('i', $_SESSION['user_id']);
    $stmt->execute();
    $stmt->store_result();

    $datasets = [];

    $stmt->bind_result($id, $title, $description, $version);
    while ($row = $stmt->fetch()) {
      $datasets[] = [
        'id' => $id,
        'title' => $title,
        'description' => $description,
        'version' => $version,
      ];
    }

    return $datasets;
  }
  return [];
}

function get_dataset($dataset_id, $mysqli) {
  if ($stmt = $mysqli->prepare("SELECT id, title, description, version
    FROM datasets
    WHERE id = ?
    AND user_id = ?")) {
    $stmt->bind_param('ii', $dataset_id, $_SESSION['user_id']);
    $stmt->execute();
    $stmt->store_result();

    $stmt->bind_result($id, $title, $description, $version);
    $stmt->fetch();
    if ($stmt->num_rows == 1) {
      return [
        'id' => $id,
        'title' => $title,
        'description' => $description,
        'version' => $version,
      ];
    }
  }
  return null;
}

function publish_dataset($dataset_id, $title, $description, $upload_id, $mysqli) {
  $mysqli->begin_transaction();
  if ($dataset_id <= 0) {
    // New dataset
    if ($stmt = $mysqli->prepare("INSERT INTO datasets (user_id, title, description, version) VALUES (?, ?, ?, ?)")) {
      $version = 1;
      $stmt->bind_param('issi', $_SESSION['user_id'], $title, $description, $version);
      $stmt->execute();
      $dataset_id = $stmt->insert_id;
    }
    else {
      // Couldn't prepare statement
      $mysqli->rollback();
      return false;
    }
  }
  else {
    // New version of existing dataset
    if ($stmt = $mysqli->prepare("UPDATE datasets
      SET title = ?, description = ?, version = version + 1
      WHERE id = ?
      AND user_id = ?")) {
      $stmt->bind_param('ssii', $title, $description, $dataset_id, $_SESSION['user_id']);
      $stmt->execute();
      if ($stmt->affected_rows != 1) {
        // Didn't update row, maybe the user doesn't own this dataset
        $mysqli->rollback();
        return false;
      }
      $version = get_dataset($dataset_id, $mysqli)['version'];
    }
    else {
      // Couldn't prepare statement
      $mysqli->rollback();
      return false;
    }
  }

  // Insert info.json into zip, save to $dataset_id
  $zip_old = '../uploads/' . $upload_id . '.zip';
  $zip_new = '../www/datasets/' . $dataset_id . '.zip';
  $zip = new ZipArchive;
  if ($zip->open($zip_old) === TRUE) {
    $zip_info = json_encode([
      'title' => $title,
      'description' => $description,
      'id' => DATASET_PREFIX . $dataset_id,
      'version' => $version,
      'author' => $_SESSION['email'],
    ]);
    $zip->addFromString('info.json', $zip_info);
    $zip->close();
  } else {
    $mysqli->rollback();
    return false;
  }
  rename($zip_old, $zip_new);
  $mysqli->commit();
  return true;
}

function delete_dataset($dataset_id, $mysqli) {
  if ($stmt = $mysqli->prepare("DELETE FROM datasets
    WHERE id = ?
    AND user_id = ?")) {
    $stmt->bind_param('ii', $dataset_id, $_SESSION['user_id']);
    $stmt->execute();
    if ($stmt->affected_rows != 1) {
      return false;
    }
    unlink('../www/datasets/' . $dataset_id . '.zip');
    return true;
  }
  return false;
}
