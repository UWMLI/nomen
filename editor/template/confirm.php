<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Confirm dataset upload</title>
</head>
<body>

<?php

require_once '../include/validate.php';

function rmdir_rf($directory)
{
  // TODO: do this more system-independently
  system('rm -rf ' . escapeshellarg($directory));
}

$upload_id = $_SESSION['user_id'] . '_' . date('Ymd_His');

$saved_zip = '../uploads/' . $upload_id . '.zip';
if (move_uploaded_file($_FILES["upload_zip"]["tmp_name"], $saved_zip)) {
  echo "<p>Received $saved_zip.</p>";
} else {
  echo "<p>There was an error uploading the file.</p>";
  exit();
}

$zip = new ZipArchive;
if ($zip->open($saved_zip) === TRUE) {
  $extract_dir = '../uploads/' . $upload_id;
  mkdir($extract_dir);
  $zip->extractTo($extract_dir);
  $zip->close();
  printInfo($extract_dir);
  $errs = validateDataset($extract_dir);
  rmdir_rf($extract_dir);
  if (empty($errs)) {
    echo '<p>No errors found!</p>';
  }
  else {
    echo '<ul>';
    foreach ($errs as $err) {
      echo "<li>$err</li>";
    }
    echo '</ul>';
  }
} else {
  echo '<p>Failed to unzip.</p>';
}

echo '<p>';
echo 'When there are no errors, <a href="?publish='.$upload_id.'">publish your new dataset</a>.';
echo '</p>';

?>

<p>
  <a href="?list">Back to list of datasets</a>
</p>

<p>
  <a href="?logout">Logout</a>
</p>

</body>
</html>
