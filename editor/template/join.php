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
  <table>
    <tr>
      <td>Email:</td>
      <td><input type="text" name="join_email" /></td>
    </tr>
    <tr>
      <td>Password (at least 10 chars):</td>
      <td><input type="password" name="join_password" /></td>
    </tr>
    <tr>
      <td>Password (type again):</td>
      <td><input type="password" name="join_password2" /></td>
    </tr>
  </table>
  <input type="submit" value="Create account" />
</form>

<p>
  <a href="?login">Back to login</a>
</p>

</body>
</html>
