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
  return str_replace( ' ', '_', strtolower( trim($str) ) );
}

function validateDataset($dir) {
  $errors = [];

  $info = json_decode( file_get_contents("$dir/info.json") );
  $species = new parseCSV("$dir/species.csv");
  // var_dump($info->title);
  // var_dump($species->data[0]['name']);
  // var_dump($species->titles[0]);

  // Find all species images
  $img_species = [];
  foreach (scandir_real("$dir/species") as $img) {
    if ( preg_match('/^(\w+)-[\w-]+\.(png|jpg)$/', $img, $matches) ) {
      $img_species[ $matches[1] ] = true;
    }
    else {
      $errors["Couldn't parse species image: $img"] = true;
    }
  }

  // Find all species in the CSV
  $csv_species = [];
  foreach ($species->data as $spec) {
    $csv_species[ canonical( $spec['name'] ) ] = true;
  }

  // Find all feature images
  $feature_dirs = scandir_real("$dir/features");
  $img_features = [];
  foreach ($feature_dirs as $feature) {
    $img_features[$feature] = [];
    foreach (scandir_real("$dir/features/$feature") as $image) {
      $ext = substr($image, -4);
      if ($ext == '.png' || $ext == '.jpg') {
        $img_features[$feature][substr($image, 0, -4)] = true;
      }
      else {
        $errors["Feature image couldn't be parsed: $feature/$image"] = true;
      }
      $img_features[$feature][$image] = true;
    }
  }

  // Find all features which are present in the species
  $spec_features = [];
  foreach ($species->data as $spec) {
    foreach ($spec as $k => $vstr) {
      $k = canonical($k);
      if ($k == 'name' || $k == 'display_name' || $k == 'description') continue;

      if ( empty($spec_features[$k]) )
      {
        $spec_features[$k] = [];
      }
      $values = array_map( 'trim', explode(',', $vstr) );
      foreach ($values as $v) {
        $spec_features[$k][canonical($v)] = true;
      }
    }
  }

  // Validation: find feature images which aren't used by any species
  // TODO

  // Validation: find species features which don't have images
  // TODO

  // Validation: find species images which don't have CSV rows
  foreach (array_diff_key($img_species, $csv_species) as $spec => $v) {
    $errors["Species has image but no CSV row: $spec"] = true;
  }

  // Validation: find species rows which don't have images
  foreach (array_diff_key($csv_species, $img_species) as $spec => $v) {
    $errors["Species has CSV row but no image: $spec"] = true;
  }

  var_dump($errors);
}

validateDataset(realpath(dirname(__FILE__)) . '/../fieldguide/plants');
