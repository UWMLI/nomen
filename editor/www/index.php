<?php

require_once '../include/config.php';
require_once '../include/db.php';
require_once '../include/session.php';
require_once '../include/datasets.php';
require_once '../include/validate.php';
sec_session_start();

/* List of commands
DEFAULT ACTIONS
  logged in: show list of datasets
  not logged in: show login page
index/list/""
  (default actions)
login
  not logged in: try to log in
    successful: show list with "logged in" message
    unsuccessful: show login page with "login failed" message
logout
  logged in: log out, show login page with "logged out" message
join
  not logged in: show new account page
signup(email, pw1, pw2)
  not logged in: try to make new account with info
    successful: show login page, with email filled in
    unsuccessful: show new account page with error message, and email filled in
upload(dataset_id or null)
  logged in: show upload page for dataset_id or new dataset
confirm(zip_file)
  logged in: extract zip and error check, show confirm page with errors
publish(zip_filename)
  logged in: try to publish zip
    successful: show list page, with "publish successful" message
    unsuccessful: not sure. show list, with "try again from the start" message?
    (this could happen if you refresh /?publish for an already published zip)
delete(dataset_id)
  logged in: delete dataset
    successful: show list with "deleted xyz" message
    unsuccessful: not sure. show list, with "couldn't delete xyz" message?
    (shouldn't happen unless you refresh /?delete)
*/

/* List of pages
login
list
join
upload
confirm
*/

$action = '';
foreach ($_GET as $k => $v) {
  $action = $k;
}

$logged_in = login_check($mysqli);
$message = '';

function in_post($strs) {
  foreach ($strs as $str) {
    if (!isset($_POST[$str])) return false;
  }
  return true;
}

function rmdir_rf($directory)
{
  // TODO: do this more system-independently
  system('rm -rf ' . escapeshellarg($directory));
}

// ACTIONS

switch ($action) {
  case 'login':
    if (!$logged_in) {
      if ( in_post(['login_email', 'login_password']) ) {
        $logged_in = login($_POST['login_email'], $_POST['login_password'], $mysqli);
      }
      $message = $logged_in ? 'Logged in successfully.' : 'Login failed.';
    }
    goto defaultPage;

  case 'logout':
    if ($logged_in) {
      logout();
      $logged_in = false;
      $message = 'Logged out.';
    }
    goto defaultPage;

  case 'join':
    if (!$logged_in) {
      include '../template/join.php';
      break;
    }
    goto defaultPage;

  case 'signup':
    if (!$logged_in) {
      if ( in_post(['join_email', 'join_password', 'join_password2']) ) {
        $email = $_POST['join_email'];
        $password = $_POST['join_password'];
        $password2 = $_POST['join_password2'];

        if ($password !== $password2) {
          $message = 'Your passwords did not match.';
        }
        else if (strlen($password) < 10) {
          $message = 'Your password must be at least 10 characters.';
        }
        else if ( !filter_var($email, FILTER_VALIDATE_EMAIL) ) {
          $message = 'Email address is invalid.';
        }
        else {
          if ( create_account($email, $password, $mysqli) ) {
            $message = 'Account created successfully. You may now login.';
          }
          else {
            $message = 'Could not create an account. Does this email already have an account?';
          }
          include '../template/login.php';
          break;
        }
        include '../template/join.php';
        break;
      }
    }
    goto defaultPage;

  case 'upload':
    if ($logged_in) {
      $dataset_id = in_post(['dataset_id']) ? (int) $_POST['dataset_id'] : 0;
      include '../template/upload.php';
      break;
    }
    goto defaultPage;

  case 'confirm':
    if ($logged_in) {
      $dataset_id = in_post(['dataset_id']) ? (int) $_POST['dataset_id'] : 0;
      $upload_id = $_SESSION['user_id'] . '_' . date('Ymd_His');
      $saved_zip = '../uploads/' . $upload_id . '.zip';
      if ( move_uploaded_file($_FILES["upload_zip"]["tmp_name"], $saved_zip) ) {
        $zip = new ZipArchive;
        if ($zip->open($saved_zip) === TRUE) {
          $extract_dir = '../uploads/' . $upload_id;
          mkdir($extract_dir);
          $zip->extractTo($extract_dir);
          $zip->close();
          $dataset_errors = validateDataset($extract_dir);
          rmdir_rf($extract_dir);
          include '../template/confirm.php';
        } else {
          $message = 'Failed to extract your zip file.';
          include '../template/upload.php';
        }
      }
      else {
        $message = 'There was an error uploading your file.';
        include '../template/upload.php';
      }
      break;
    }
    goto defaultPage;

  case 'publish':
    if ($logged_in) {
      if ( in_post(['dataset_id', 'dataset_title', 'dataset_description', 'upload_id']) ) {
        if ( publish_dataset($_POST['dataset_id'], $_POST['dataset_title'], $_POST['dataset_description'], $_POST['upload_id'], $mysqli) ) {
          $message = 'Publish successful!';
        }
        else {
          $message = 'Publish was not successful. Try again from the beginning.';
        }
      }
    }
    goto defaultPage;

  case 'delete':
    if ($logged_in) {
      if ( in_post(['dataset_id']) ) {
        if ( delete_dataset($_POST['dataset_id'], $mysqli) ) {
          $message = 'Dataset deleted.';
        }
        else {
          $message = 'There was an error deleting that dataset.';
        }
      }
    }
    goto defaultPage;

  default:
  defaultPage:
    if ($logged_in) {
      include '../template/list.php';
    }
    else {
      include '../template/login.php';
    }
}
