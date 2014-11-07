<?php 

$page_title = 'Your Guides';
function page_content() {
  ?>

<div class="page-header">
<h1>Your guides</h1>
</div>

<div class="table-responsive">
<table class="table table-striped">
  <tr>
    <th>Title</th>
    <th>Version</th>
    <th>Description</th>
    <th>New version</th>
    <th>Download</th>
    <th>Delete</th>
  </tr>
  <?php

  require_once '../include/datasets.php';

  $sets = get_datasets();
  foreach ($sets as $set) {
    ?>
    <tr>
      <td><?= htmlspecialchars($set['title']) ?></td>
      <td><?= $set['version'] ?></td>
      <td><?= htmlspecialchars($set['description']) ?></td>
      <td>
        <form action="?upload" method="post">
          <input class="btn btn-primary" type="submit" value="New version" />
          <input type="hidden" name="dataset_id" value="<?= $set['id'] ?>" />
        </form>
      </td>
      <td>
        <a href="datasets/<?= $set['id'] ?>.zip">
          <button class="btn btn-info">Download</button>
        </a>
      </td>
      <td>
        <form action="?delete" method="post">
          <input class="btn btn-danger" type="submit" value="Delete" />
          <input type="hidden" name="dataset_id" value="<?= $set['id'] ?>" />
        </form>
      </td>
    </tr>
    <?php
  }

  ?>
</table>
</div>

  <?php
}

include 'template.php';
