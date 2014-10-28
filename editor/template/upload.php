<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Field Guide Upload</title>
</head>
<body>

<?php

if ($dataset_id <= 0) {
  echo '<h1>Upload a new dataset</h1>';
}
else {
  echo "<h1>Upload a new version of dataset $dataset_id</h1>";
}

?>

<form action="?confirm" method="post" enctype="multipart/form-data">
  <p>
    Please select your zip file: <input type="file" name="uploadFile">
  </p>
  <p>
    <input type="submit" value="Upload file">
  </p>
</form>

<p>
  <a href="?list">Back to list of datasets</a>
</p>

<p>
  <a href="?logout">Logout</a>
</p>

</body>
</html>
