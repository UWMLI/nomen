<?php 

$page_title = 'Login';
function page_content() {
  $existing_email = isset($_POST['email']) ? $_POST['email'] : '';
  ?>

<form action="?login" method="post">
  <table>
    <tr>
      <td>Email:</td>
      <td><input type="text" name="email" value="<?= $existing_email ?>" /></td>
    </tr>
    <tr>
      <td>Password:</td>
      <td><input type="password" name="password" /></td>
    </tr>
  </table>
  <input type="submit" value="Login" />
</form>

<p>
  <a href="?join">Create new account</a>
</p>

  <?php
}

include 'template.php';
