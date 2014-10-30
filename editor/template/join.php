<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Create an account</title>
</head>
<body>

<h1>Create an account</h1>

<?php

if ($message) {
  echo "<p><b>$message</b></p>";
}

$existing_email = isset($_POST['join_email']) ? $_POST['join_email'] : '';

?>

<form action="?signup" method="post">
  <table>
    <tr>
      <td>Email:</td>
      <td><input type="text" name="join_email" value="<?= $existing_email ?>" /></td>
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
  <a href="?">Back to login</a>
</p>

</body>
</html>
