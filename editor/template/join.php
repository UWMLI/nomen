<?php 

$page_title = 'Create an Account';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<div class="page-header">
<h1>Create an account</h1>
</div>

<form action="?signup" method="post">
  <div class="form-group">
    <input autofocus placeholder="Email" type="text" name="email" value="<?= $existing_email ?>" />
  </div>
  <div class="form-group">
    <input placeholder="Password" type="password" name="password" />
  </div>
  <div class="form-group">
    <input placeholder="Password (again)" type="password" name="password2" />
  </div>
  <div class="form-group">
    <input type="submit" value="Create account" class="btn btn-primary" />
  </div>
</form>

  <?php
}

include 'template.php';
