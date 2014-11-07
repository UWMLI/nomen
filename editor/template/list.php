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
        <button class="btn btn-danger" type="submit"
          data-toggle="modal" data-target="#delete-modal-<?= $set['id'] ?>">
          Delete
        </button>
      </td>
    </tr>
    <?php
  }

  ?>
</table>
</div>

<?php foreach ($sets as $set) { ?>
  <div class="modal" id="delete-modal-<?= $set['id'] ?>" tabindex="-1" role="dialog"
    aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">&times;</span>
            <span class="sr-only">Close</span>
          </button>
          <h4 class="modal-title" id="myModalLabel">Confirm delete</h4>
        </div>
        <div class="modal-body">
          <p>
            Are you sure you want to delete the
            &ldquo;<?= htmlspecialchars($set['title']) ?>&rdquo;
            guide?
          </p>
        </div>
        <div class="modal-footer">
          <form action="?delete" method="post">
            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            <input type="submit" class="btn btn-danger" value="Delete" />
            <input type="hidden" name="dataset_id" value="<?= $set['id'] ?>" />
          </form>
        </div>
      </div>
    </div>
  </div>
<?php } ?>

  <?php
}

include 'template.php';
