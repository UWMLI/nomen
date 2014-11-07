<?php 

$page_title = 'Your Guides';
function page_content() {
  ?>

<div class="page-header">
<h1>Your guides</h1>
</div>

<div class="table-responsive" id="no-more-tables">
<table class="table table-striped">
  <thead>
    <tr>
      <th>Title</th>
      <th>Version</th>
      <th>Description</th>
      <th>New version</th>
      <th>Download</th>
      <th>Delete</th>
    </tr>
  </thead>
  <tbody>
  <?php

  require_once '../include/datasets.php';

  $sets = get_datasets();
  foreach ($sets as $set) {
    ?>
    <tr>
      <td data-title="Title"><?= htmlspecialchars($set['title']) ?></td>
      <td data-title="Version"><?= $set['version'] ?></td>
      <td data-title="Description"><?= htmlspecialchars($set['description']) ?></td>
      <td data-title="New version">
        <form action="?upload" method="post">
          <input class="btn btn-primary" type="submit" value="New version" />
          <input type="hidden" name="dataset_id" value="<?= $set['id'] ?>" />
        </form>
      </td>
      <td data-title="Download">
        <a href="datasets/<?= $set['id'] ?>.zip">
          <button class="btn btn-info">Download</button>
        </a>
      </td>
      <td data-title="Delete">
        <button class="btn btn-danger" type="submit"
          data-toggle="modal" data-target="#delete-modal-<?= $set['id'] ?>">
          Delete
        </button>
      </td>
    </tr>
    <?php
  }

  ?>
  </tbody>
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
