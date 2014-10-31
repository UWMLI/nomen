<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Field Guide: <?php echo $page_title; ?></title>
  <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>

<?php
if ($message) {
  echo "<p><b>$message</b></p>";
}
?>

<?php page_content(); ?>

</body>
</html>
