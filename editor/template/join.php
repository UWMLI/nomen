<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Create an account</title>
</head>
<body>

<h1>Create an account</h1>

<?php

if ($join_message !== '') {
  echo "<p>$join_message</p>";
}

?>

<form action="?join" method="post">
  <p>Email:                        <input type="text"     name="join_email"    /></p>
  <p>Password (at least 10 chars): <input type="password" name="join_password" /></p>
  <p>Password (type again):        <input type="password" name="join_password2" /></p>
  <p><input type="submit" value="Create account" /></p>
</form>

<p>
  <a href="?login">Back to login</a>
</p>

</body>
</html>
