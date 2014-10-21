<?php

require_once 'parsecsv.lib.php';

function scandir_real($dir) {
  if (!is_dir($dir))
  {
    return [];
  }
  $entries = [];
  foreach (scandir($dir) as $f) {
    if ( substr($f, 0, 1) != '.' ) {
      $entries[] = $f;
    }
  }
  return $entries;
}

function canonical($str) {
  return str_replace( ' ', '_', strtolower( trim($str) ) );
}

function printInfo($dir) {
  $info = json_decode( file_get_contents("$dir/info.json") );
  echo "<h1>$info->title v$info->version</h1>";
}

function validateDataset($dir) {
  $errors = [];

  $species = new parseCSV("$dir/species.csv");

  $species_canonical = [];
  foreach ($species->data as $spec) {
    $spec_canonical = [];
    foreach ($spec as $k => $v) {
      $spec_canonical[ canonical($k) ] = $v;
    }
    $species_canonical[] = $spec_canonical;
  }

  // Find all species images
  $img_species = [];
  foreach (scandir_real("$dir/species") as $img) {
    if ( preg_match('/^([\w ]+)(-[\w -]+)?\.[A-Za-z]+$/', $img, $matches) ) {
      $img_species[ canonical($matches[1]) ] = true;
    }
    else {
      $errors[] = "Couldn't parse species image: $img";
    }
  }

  // Find all species in the CSV
  $csv_species = [];
  foreach ($species_canonical as $spec) {
    $csv_species[ canonical( $spec['name'] ) ] = true;
  }

  // Find all feature images
  $img_features = [];
  foreach (scandir_real("$dir/features") as $feature) {
    $img_features[canonical($feature)] = [];
    foreach (scandir_real("$dir/features/$feature") as $image) {
      $extension_dot = strrpos($image, '.');
      if ($extension_dot !== false) {
        $img_features[canonical($feature)][canonical(substr($image, 0, $extension_dot))] = true;
      }
      else {
        $errors[] = "Feature image couldn't be parsed: $feature/$image";
      }
    }
  }

  // Find all features which are present in the species
  $csv_features = [];
  foreach ($species_canonical as $spec) {
    foreach ($spec as $k => $vstr) {
      if ($k == 'name' || $k == 'display_name' || $k == 'description') continue;

      if ( empty($csv_features[$k]) )
      {
        $csv_features[$k] = [];
      }
      $values = array_map( 'trim', explode(',', $vstr) );
      foreach ($values as $v) {
        if (empty($v)) continue;
        $csv_features[$k][canonical($v)] = true;
      }
    }
  }

  // Validation: find feature images which aren't used by any species
  foreach (array_diff_key($img_features, $csv_features) as $feature => $_) {
    $errors[] = "Feature with image folder doesn't have a column in CSV: $feature";
  }
  foreach (array_intersect_key($img_features, $csv_features) as $feature => $_)
  {
    foreach (array_diff_key($img_features[$feature], $csv_features[$feature]) as $value => $_) {
      $errors[] = "Feature image isn't used by any species: $feature -> $value";
    }
  }

  // Validation: find species features which don't have images
  foreach (array_diff_key($csv_features, $img_features) as $feature => $_) {
    $errors[] = "Feature in CSV doesn't have image folder: $feature";
  }
  foreach (array_intersect_key($csv_features, $img_features) as $feature => $_)
  {
    foreach (array_diff_key($csv_features[$feature], $img_features[$feature]) as $value => $_) {
      $errors[] = "Feature value in CSV doesn't have an image: $feature -> $value";
    }
  }

  // Validation: find species images which don't have CSV rows
  foreach (array_diff_key($img_species, $csv_species) as $spec => $_) {
    $errors[] = "Species has image but no CSV row: $spec";
  }

  // Validation: find species rows which don't have images
  foreach (array_diff_key($csv_species, $img_species) as $spec => $_) {
    $errors[] = "Species has CSV row but no image: $spec";
  }

  return $errors;
}
