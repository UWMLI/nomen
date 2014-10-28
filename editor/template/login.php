<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Login</title>
</head>
<body>

<?php

if ($login_failed) {
  echo '<p>Login failed.</p>';
}
else if ($joined) {
  echo '<p>Account created. You may now log in.</p>';
}

?>

<form action="?list" method="post">
  <table>
    <tr>
      <td>Email:</td>
      <td><input type="text" name="login_email" /></td>
    </tr>
    <tr>
      <td>Password:</td>
      <td><input type="password" name="login_password" /></td>
    </tr>
  </table>
  <input type="submit" value="Login" />
</form>

<p>
  <a href="?join">Create new account</a>
</p>

</body>
</html>
