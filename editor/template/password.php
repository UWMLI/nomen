<?php 

$page_title = 'Change Password';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<form action="?change" method="post">
  <input placeholder="Old password" type="password" name="old_password" />
  <input placeholder="New password" type="password" name="password" />
  <input placeholder="New password (again)" type="password" name="password2" />
  <input type="submit" value="Change password" />
</form>

<p>
  <a href="?">Back</a>
</p>

  <?php
}

include 'template.php';
