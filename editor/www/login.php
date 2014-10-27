<?php

require_once '../include/db.php';
require_once '../include/session.php';

sec_session_start();

?>

<!DOCTYPE html>
<html>
<head>
  <title>Login</title>
</head>
<body>

<?php

echo '<p>';
if ( isset($_POST['email'], $_POST['password']) ) {
  if ( login($_POST['email'], $_POST['password'], $mysqli) ) {
    echo 'Login successful!';
  }
  else {
    echo 'Login failed.';
  }
}
else {
  if ( login_check($mysqli) ) {
    echo 'Currently logged in.';
  }
  else {
    echo 'Not currently logged in.';
  }
}
echo '</p>';

?>

<form action="login.php" method="post">
  <p>Email: <input type="text" name="email" /></p>
  <p>Password: <input type="password" name="password" /></p>
  <p><input type="submit" /></p>
</form>

</body>
</html>
