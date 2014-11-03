<?php

require_once '../include/datasets.php';

$page_title = 'Upload';
function page_content() {
  global $dataset_id;
  ?>

<h1>
  <?php
    if ($dataset_id <= 0) {
      echo 'Upload a new dataset';
    }
    else {
      $title = htmlspecialchars(get_dataset($dataset_id)['title']);
      echo "Upload a new version of dataset &ldquo;$title&rdquo;";
    }
  ?>
</h1>

<form action="?confirm" method="post" enctype="multipart/form-data">
  <p>
    Please select your zip file: <input type="file" name="upload_zip">
  </p>
  <p>
    <input type="submit" value="Upload file">
  </p>
  <input type="hidden" name="dataset_id" value="<?php echo $dataset_id; ?>" />
</form>

  <?php
}

include 'template.php';
