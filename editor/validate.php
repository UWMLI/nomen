<?php

require_once 'parsecsv.lib.php';

function validateDataset($dir) {
  $info = json_decode( file_get_contents("$dir/info.json") );
  $species = (new parseCSV("$dir/species.csv"))->data;
  var_dump($info->title);
  var_dump($species[0]['name']);
}

validateDataset(realpath(dirname(__FILE__)) . '/../fieldguide/plants');
