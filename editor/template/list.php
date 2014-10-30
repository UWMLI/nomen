<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Field Guide Datasets</title>
</head>
<body>

<?php

if ($message) {
  echo "<p><b>$message</b></p>";
}

?>

<p>
  Logged in as <?php echo $_SESSION['email'] ?>.
</p>

<table>
  <tr>
    <th>ID</th>
    <th>Title</th>
    <th>Version</th>
    <th>Description</th>
    <th>Upload new version</th>
    <th>Download .zip</th>
    <th>Delete</th>
  </tr>
  <?php

  require_once '../include/datasets.php';

  $sets = get_datasets($mysqli);
  foreach ($sets as $set) {
    ?>
    <tr>
      <td><?= $set['id'] ?></td>
      <td><?= htmlspecialchars($set['title']) ?></td>
      <td><?= $set['version'] ?></td>
      <td><?= htmlspecialchars($set['description']) ?></td>
      <td>
        <form action="?upload" method="post">
          <input type="submit" value="New version">
          <input type="hidden" name="dataset_id" value="<?= $set['id'] ?>" />
        </form>
      </td>
      <td>
        <a href="datasets/<?= $set['id'] ?>.zip">Download</a>
      </td>
      <td>
        <form action="?delete" method="post">
          <input type="submit" value="Delete">
          <input type="hidden" name="dataset_id" value="<?= $set['id'] ?>" />
        </form>
      </td>
    </tr>
    <?php
  }

  ?>
</table>

<p>
  <a href="?upload">Create new dataset</a>
</p>

<p>
  <a href="?logout">Logout</a>
</p>

</body>
</html>
