<?php

require_once '../include/config.php';
require_once '../include/db.php';
require_once '../include/session.php';
require_once '../include/datasets.php';
require_once '../include/validate.php';
sec_session_start();

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
      if ( in_post(['email', 'password']) ) {
        $logged_in = login($_POST['email'], $_POST['password'], $mysqli);
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
      if ( in_post(['email', 'password', 'password2']) ) {
        $email = $_POST['email'];
        $password = $_POST['password'];
        $password2 = $_POST['password2'];

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

  case 'password':
    if ($logged_in) {
      include '../template/password.php';
      break;
    }
    goto defaultPage;

  case 'change':
    if ($logged_in) {
      if ( in_post(['old_password', 'password', 'password2']) ) {
        if ($_POST['password'] !== $_POST['password2']) {
          $message = 'Passwords did not match.';
        }
        else if (strlen($_POST['password']) < 10) {
          $message = 'Your password must be at least 10 characters.';
        }
        else {
          if (change_password($_POST['old_password'], $_POST['password'], $mysqli)) {
            $message = 'Password changed successfully.';
            goto defaultPage;
          }
          else {
            $message = 'Old password was not correct.';
          }
        }
        include '../template/password.php';
        break;
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
