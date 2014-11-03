<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Field Guide: <?php echo $page_title; ?></title>

  <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
  <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.0/css/bootstrap.min.css">
  <!-- Optional theme -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.0/css/bootstrap-theme.min.css">
  <!-- Latest compiled and minified JavaScript -->
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1">

</head>
<body>

<nav class="navbar navbar-inverse" role="navigation">
  <div class="container">
    <div class="navbar-header">
      <a class="navbar-brand" href="?">Field Guide</a>
    </div>
    <div class="navbar-collapse">
      <?php if ($logged_in) { ?>
        <p class="navbar-text">
          Logged in as
          <?= $_SESSION['email'] ?>
        </p>
        <p class="navbar-text">
          <a class="navbar-link" href="?logout">Logout</a>
        </p>
      <?php } ?>
    </div>
  </div>
</nav>

<div class="container">

<?php
if ($message) {
  echo "<div class=\"alert alert-info\">$message</div>";
}
?>

<?php page_content(); ?>

</div>

</body>
</html>
