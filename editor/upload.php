<?php

/*
Note, for this to work you must set BOTH upload_max_filesize AND post_max_size
to a high enough value.
*/

ini_set('display_errors', true);
error_reporting(E_ALL);

require_once 'validate.php';

function rmdir_rf($directory)
{
  // TODO: do this more system-independently
  system('rm -rf ' . escapeshellarg($directory));
}

$target_dir = "uploads/";
rmdir_rf($target_dir);
mkdir($target_dir);
$target_dir = $target_dir . basename( $_FILES["uploadFile"]["name"]);

if (move_uploaded_file($_FILES["uploadFile"]["tmp_name"], $target_dir)) {
  echo "Received file ". basename( $_FILES["uploadFile"]["name"]). ".";
} else {
  echo "There was an error uploading the file.";
  exit();
}

$zip = new ZipArchive;
if ($zip->open($target_dir) === TRUE) {
  rmdir_rf('extract/');
  mkdir('extract/');
  $zip->extractTo('extract/');
  $zip->close();
  $errs = validateDataset('extract/');
  rmdir_rf('extract/');
  echo '<ul>';
  foreach ($errs as $err) {
    echo "<li>$err</li>";
  }
  echo '</ul>';
} else {
  echo 'Failed to unzip.';
}

rmdir_rf('uploads/');
