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

?>

<form action="?list" method="post">
  <p>Email:    <input type="text"     name="login_email"    /></p>
  <p>Password: <input type="password" name="login_password" /></p>
  <p><input type="submit" value="Login" /></p>
</form>

<p>
  <a href="?join">Create new account</a>
</p>

</body>
</html>
