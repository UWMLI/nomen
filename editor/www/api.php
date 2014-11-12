<?php

require_once '../include/db.php';

header('Content-Type: application/json');

$datasets = array();
$rows = DB::query('SELECT d.id, d.title, d.version, d.description, u.email
  FROM datasets AS d
  LEFT JOIN users AS u ON d.user_id = u.id');
foreach ($rows as $row) {
  if ( file_exists($icon_maybe = 'datasets/' . $row['id'] . '.png') ) {
    $icon = $icon_maybe;
  }
  else if ( file_exists($icon_maybe = 'datasets/' . $row['id'] . '.jpg') ) {
    $icon = $icon_maybe;
  }
  else {
    $icon = null;
  }
  $datasets[] = array(
    'id' => DATASET_PREFIX . $row['id'],
    'title' => $row['title'],
    'version' => $row['version'],
    'description' => $row['description'],
    'author' => $row['email'],
    'url' => 'datasets/' . $row['id'] . '.zip',
    'icon' => $icon,
  );
}
echo json_encode($datasets);
