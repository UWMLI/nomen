<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Confirm dataset upload</title>
</head>
<body>

<?php

require_once '../include/validate.php';

$upload_id = $_SESSION['user_id'] . '_' . date('Ymd_His');

$saved_zip = '../uploads/' . $upload_id . '.zip';
if (move_uploaded_file($_FILES["upload_zip"]["tmp_name"], $saved_zip)) {
  echo "<p>Received $saved_zip.</p>";
} else {
  echo "<p>There was an error uploading the file.</p>";
  exit();
}

?>

<p>
  <a href="?list">Back to list of datasets</a>
</p>

<p>
  <a href="?logout">Logout</a>
</p>

</body>
</html>
