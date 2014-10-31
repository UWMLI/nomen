<?php 

$page_title = 'Change Password';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<form action="?change" method="post">
  <table>
    <tr>
      <td>Old password:</td>
      <td><input type="password" name="old_password" /></td>
    </tr>
    <tr>
      <td>New password (at least 10 chars):</td>
      <td><input type="password" name="password" /></td>
    </tr>
    <tr>
      <td>New password (type again):</td>
      <td><input type="password" name="password2" /></td>
    </tr>
  </table>
  <input type="submit" value="Change password" />
</form>

<p>
  <a href="?">Back</a>
</p>

  <?php
}

include 'template.php';
