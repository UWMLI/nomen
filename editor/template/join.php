<?php 

$page_title = 'Create an Account';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<form action="?signup" method="post">
  <input placeholder="Email" type="text" name="email" value="<?= $existing_email ?>" />
  <input placeholder="Password" type="password" name="password" />
  <input placeholder="Password (again)" type="password" name="password2" />
  <input type="submit" value="Create account" />
</form>

<p>
  <a href="?">Back to login</a>
</p>

  <?php
}

include 'template.php';
