<?php

require_once '../include/db.php';

header('Content-Type: application/json');

$datasets = array();
$rows = DB::query('SELECT d.id, d.title, d.version, d.description, u.email
  FROM datasets AS d
  LEFT JOIN users AS u ON d.user_id = u.id');
foreach ($rows as $row) {
  $icon = 'datasets/' . $row['id'] . '.png';
  if ( !file_exists($icon) ) {
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
