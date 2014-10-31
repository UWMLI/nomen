<?php

require_once 'config.php';
require_once 'meekrodb.2.3.class.php';

$mysqli = new mysqli(HOST, USER, PASSWORD, DATABASE, PORT);
$mysqli->set_charset("utf8");

DB::$host = HOST;
DB::$user = USER;
DB::$password = PASSWORD;
DB::$dbName = DATABASE;
DB::$port = PORT;
DB::$encoding = 'utf8';

DB::$error_handler = false;
DB::$throw_exception_on_error = false;
