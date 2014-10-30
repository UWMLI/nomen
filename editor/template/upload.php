<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Field Guide Upload</title>
</head>
<body>

<?php

if ($message) {
  echo "<p><b>$message</b></p>";
}

?>

<?php

require_once '../include/datasets.php';

if ($dataset_id <= 0) {
  echo '<h1>Upload a new dataset</h1>';
}
else {
  $title = htmlspecialchars(get_dataset($dataset_id)['title']);
  echo "<h1>Upload a new version of dataset &ldquo;$title&rdquo;</h1>";
}

?>

<form action="?confirm" method="post" enctype="multipart/form-data">
  <p>
    Please select your zip file: <input type="file" name="upload_zip">
  </p>
  <p>
    <input type="submit" value="Upload file">
  </p>
  <input type="hidden" name="dataset_id" value="<?php echo $dataset_id; ?>" />
</form>

<p>
  <a href="?list">Back to list of datasets</a>
</p>

<p>
  <a href="?logout">Logout</a>
</p>

</body>
</html>
