<?php 

$page_title = 'Confirmation';
function page_content() {
  global $dataset_id, $dataset_errors, $upload_id;

  if ( empty($dataset_errors) ) {
    echo '<p>No errors found in your dataset!</p>';
  }
  else {
    echo '<p>Found the following errors:</p>';
    echo '<ul>';
    foreach ($dataset_errors as $err) {
      echo "<li>$err</li>";
    }
    echo '</ul>';
  }

  $existing_title       = '';
  $existing_description = '';
  if ($dataset_id > 0) {
    $set = get_dataset($dataset_id);
    $existing_title       = $set['title'];
    $existing_description = $set['description'];
  }
  ?>

<p>When there are no errors, enter a title and publish your dataset.</p>

<form action="?publish" method="post">
  <div class="form-group">
    <input placeholder="Title" type="text" name="dataset_title" value="<?= $existing_title ?>" />
  </div>
  <div class="form-group">
    <input placeholder="Description" type="text" name="dataset_description" value="<?= $existing_description ?>" />
  </div>
  <div class="form-group">
    <input type="submit" value="Publish" class="btn btn-primary" />
  </div>
  <input type="hidden" name="dataset_id" value="<?= $dataset_id ?>" />
  <input type="hidden" name="upload_id" value="<?= $upload_id ?>" />
</form>

  <?php
}

include 'template.php';
