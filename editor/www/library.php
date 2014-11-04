<?php

require_once '../include/db.php';

header('Content-Type: application/json');

$datasets = [];
$rows = DB::query('SELECT id FROM datasets');
foreach ($rows as $row) {
  $datasets[] = 'datasets/' . $row['id'] . '/';
}
echo json_encode($datasets, JSON_PRETTY_PRINT);
