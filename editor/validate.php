<?php

require_once 'parsecsv.lib.php';

function scandir_real($dir) {
  $entries = [];
  foreach (scandir($dir) as $f) {
    if ( substr($f, 0, 1) != '.' ) {
      array_push($entries, $f);
    }
  }
  return $entries;
}

function validateDataset($dir) {
  $info = json_decode( file_get_contents("$dir/info.json") );
  $species = new parseCSV("$dir/species.csv");
  var_dump($info->title);
  var_dump($species->data[0]['name']);
  var_dump($species->titles[0]);

  $species_images = scandir_real("$dir/species");
  var_dump($species_images[0]);

  $feature_dirs = scandir_real("$dir/features");
  $features = [];
  foreach ($feature_dirs as $feature) {
    $features[$feature] = scandir_real("$dir/features/$feature");
  }
  var_dump($features['stem_texture'][0]);
}

validateDataset(realpath(dirname(__FILE__)) . '/../fieldguide/plants');
