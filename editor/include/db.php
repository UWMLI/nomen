<?php

require_once 'config.php';

$mysqli = new mysqli(HOST, USER, PASSWORD, DATABASE, PORT);
$mysqli->set_charset("utf8");
