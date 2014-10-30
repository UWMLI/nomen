<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Change your password</title>
</head>
<body>

<h1>Change your password</h1>

<?php

if ($message) {
  echo "<p><b>$message</b></p>";
}

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

</body>
</html>
