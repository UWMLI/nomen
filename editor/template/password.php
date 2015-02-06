<?php 

$page_title = 'Change Password';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<div class="page-header">
<h1>Change your password</h1>
</div>

<form action="?change" method="post">
  <div class="form-group">
    <label for="input-old-password">Old password</label>
    <input autofocus id="input-old-password" class="form-control" placeholder="Old password" type="password" name="old_password" />
  </div>
  <div class="form-group">
    <label for="input-password">New password</label>
    <input id="input-password" class="form-control" placeholder="New password" type="password" name="password" />
  </div>
  <div class="form-group">
    <label for="input-password2">New password (again)</label>
    <input id="input-password2" class="form-control" placeholder="New password (again)" type="password" name="password2" />
  </div>
  <div class="form-group">
    <input type="submit" value="Change password" class="btn btn-primary" />
  </div>
</form>

  <?php
}

include 'template.php';
