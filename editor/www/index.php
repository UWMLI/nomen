<?php

require_once '../include/config.php';
require_once '../include/db.php';
require_once '../include/session.php';
sec_session_start();

$login_failed = false;
if ( isset($_POST['login_email'], $_POST['login_password']) ) {
  $login_failed = !login($_POST['login_email'], $_POST['login_password'], $mysqli);
}

$logged_in = login_check($mysqli);

$action = $logged_in ? 'list' : 'login';
$dataset_id = 0;

foreach ( $_GET as $k => $v ) {
  if ( $logged_in ) {
    if ( $k === 'list' ) {
      $action = $k;
    }
    else if ( $k === 'upload' || $k === 'confirm' ) {
      $action = $k;
      $dataset_id = (int) $v;
    }
    else if ( $k === 'logout' ) {
      logout();
      $logged_in = false;
      $action = 'login';
    }
  }
  else {
    if ( $k === 'login' || $k === 'join' ) {
      $action = $k;
    }
  }
}

switch ( $action ) {
  case 'login':
    include '../template/login.php';
    break;
  case 'join':
    break;
  case 'list':
    include '../template/list.php';
    break;
  case 'upload':
    include '../template/upload.php';
    break;
  case 'confirm':
    break;
}
