<?php 

$page_title = 'Login';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<h1>Field Guide</h1>

<form action="?login" method="post">
  <input placeholder="Email" type="text" name="email" value="<?= $existing_email ?>" />
  <input placeholder="Password" type="password" name="password" />
  <input type="submit" value="Login" />
</form>

<form action="?join" method="post">
  <input type="submit" value="Register" />
</form>

  <?php
}

include 'template.php';
