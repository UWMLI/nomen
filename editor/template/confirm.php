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

<form action="?publish" method="post">
  <p>When there are no errors, enter a title and publish your dataset.</p>
  <table>
    <tr>
      <td>Title:</td>
      <td><input type="text" name="dataset_title" value="<?= $existing_title ?>" /></td>
    </tr>
    <tr>
      <td>Description:</td>
      <td><input type="text" name="dataset_description" value="<?= $existing_description ?>" /></td>
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

  <?php
}

include 'template.php';
