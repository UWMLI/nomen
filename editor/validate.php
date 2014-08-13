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

function canonical($str) {
  return str_replace( ' ', '_', strtolower($str) );
}

function validateDataset($dir) {
  $errors = [];

  $info = json_decode( file_get_contents("$dir/info.json") );
  $species = new parseCSV("$dir/species.csv");
  // var_dump($info->title);
  // var_dump($species->data[0]['name']);
  // var_dump($species->titles[0]);

  $species_images = scandir_real("$dir/species");
  // var_dump($species_images[0]);

  $feature_dirs = scandir_real("$dir/features");
  $features = [];
  foreach ($feature_dirs as $feature) {
    $features[$feature] = [];
    foreach (scandir_real("$dir/features/$feature") as $image) {
      $features[$feature][$image] = true;
    }
  }
  // var_dump($features['stem_texture'][0]);

  // Check that all features have images
  foreach ($species->data as $spec) {
    foreach ($spec as $k => $vstr) {
      $k = canonical($k);
      if ($k == 'name' || $k == 'display_name' || $k == 'description') continue;
      $values = array_map( 'trim', explode(',', $vstr) );
      if ( array_key_exists($k, $features) ) {
        foreach ($values as $value) {
          $value = canonical($value);
          if ( empty($value) ) continue;
          if ( array_key_exists("$value.png", $features[$k])
            || array_key_exists("$value.jpg", $features[$k]) ) {
            // No problem here
          }
          else
          {
            $errors["Feature value doesn't have an image: $k -> $value"] = true;
          }
        }
      }
      else {
        $errors["Feature doesn't have a folder: $k"] = true;
      }
    }
  }

  var_dump($errors);
}

validateDataset(realpath(dirname(__FILE__)) . '/../fieldguide/plants');
