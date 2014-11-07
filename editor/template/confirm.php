<?php 

$page_title = 'Confirmation';
function page_content() {
  global $dataset_id, $dataset_errors, $upload_id;

  if ( empty($dataset_errors) ) {
    echo '<p>No errors found!</p>';
  }
  else {
    echo '<p>The following errors were found:</p>';
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
    $existing_title       = htmlspecialchars($set['title']);
    $existing_description = htmlspecialchars($set['description']);
  }
  ?>

<p>
  After you have fixed any errors, enter a title and description, and publish your dataset.
</p>

<form action="?publish" method="post">
  <div class="form-group">
    <input class="form-control" placeholder="Title" type="text" name="dataset_title" value="<?= $existing_title ?>" />
  </div>
  <div class="form-group">
    <textarea class="form-control" placeholder="Description" type="text" name="dataset_description"><?= $existing_description ?></textarea>
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
