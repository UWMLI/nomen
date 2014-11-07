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
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="?">Field Guide</a>
    </div>

    <div class="collapse navbar-collapse" id="navbar-collapse">
      <?php if ($logged_in) { ?>
        <ul class="nav navbar-nav">
          <li><a href="?list">Your Datasets</a></li>
          <li><a href="?upload">New Dataset</a></li>
        </ul>

        <ul class="nav navbar-nav navbar-right">
          <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              Logged in as <?= $_SESSION['email'] ?> <span class="caret"></span>
            </a>
            <ul class="dropdown-menu" role="menu">
              <li><a href="?logout">Logout</a></li>
              <li><a href="?password">Change Password</a></li>
            </ul>
          </li>
        </ul>
      <?php } ?>
    </div>
  </div>
</nav>

<div class="container">

<?php
if ($message) {
  $message_class = $success ? 'alert-success' : 'alert-danger';
  echo "<div class=\"alert $message_class\">$message</div>";
}
?>

<?php page_content(); ?>

</div>

</body>
</html>
