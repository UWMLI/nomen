<?php 

$page_title = 'Create an Account';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<form action="?signup" method="post">
  <table>
    <tr>
      <td>Email:</td>
      <td><input type="text" name="email" value="<?= $existing_email ?>" /></td>
    </tr>
    <tr>
      <td>Password (at least 10 chars):</td>
      <td><input type="password" name="password" /></td>
    </tr>
    <tr>
      <td>Password (type again):</td>
      <td><input type="password" name="password2" /></td>
    </tr>
  </table>
  <input type="submit" value="Create account" />
</form>

<p>
  <a href="?">Back to login</a>
</p>

  <?php
}

include 'template.php';
