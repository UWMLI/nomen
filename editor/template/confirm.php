<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Confirm dataset upload</title>
</head>
<body>

<?php

require_once '../include/validate.php';
require_once '../include/datasets.php';

function rmdir_rf($directory)
{
  // TODO: do this more system-independently
  system('rm -rf ' . escapeshellarg($directory));
}

$dataset_id = isset($_POST['dataset_id']) ? (int) $_POST['dataset_id'] : 0;
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

$existing_title = $dataset_id <= 0 ? '' : get_dataset($dataset_id, $mysqli)['title'];

?>

<form action="?publish" method="post">
  <p>When there are no errors, enter a title and publish your dataset.</p>
  <table>
    <tr>
      <td>Title:</td>
      <td><input type="text" name="dataset_title" value="<?= $existing_title ?>" /></td>
    </tr>
  </table>
  <input type="submit" value="Publish" />
  <input type="hidden" name="dataset_id" value="<?= $dataset_id ?>" />
  <input type="hidden" name="upload_id" value="<?= $upload_id ?>" />
</form>

<p>
  <a href="?list">Back to list of datasets</a>
</p>

<p>
  <a href="?logout">Logout</a>
</p>

</body>
</html>
