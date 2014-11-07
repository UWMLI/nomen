<?php

require_once '../include/datasets.php';

$page_title = 'Upload';
function page_content() {
  global $dataset_id;
  ?>

<div class="page-header">
<h1>
  <?php
    if ($dataset_id <= 0) {
      echo 'Upload a new guide';
    }
    else {
      $dataset = get_dataset($dataset_id);
      $title = htmlspecialchars($dataset['title']);
      echo "Upload a new version of &ldquo;$title&rdquo;";
    }
  ?>
</h1>
</div>

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
