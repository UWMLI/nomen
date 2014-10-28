<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Field Guide Datasets</title>
</head>
<body>

<p>
  Logged in as <?php echo $_SESSION['email'] ?>.
</p>

<table>
  <tr>
    <th>ID</th>
    <th>Title</th>
    <th>Version</th>
    <th>Upload new version</th>
  </tr>
  <?php

  require_once '../include/datasets.php';

  $sets = get_datasets($_SESSION['user_id'], $mysqli);
  foreach ($sets as $set) {
    echo '<tr>';
    echo '<td>' . $set['id'] . '</td>';
    echo '<td>' . $set['title'] . '</td>';
    echo '<td>' . $set['version'] . '</td>';
    echo '<td><a href="?upload='.$set['id'].'">New version</a></td>';
    echo '</tr>';
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
