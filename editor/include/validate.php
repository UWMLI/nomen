<?php

require_once 'parsecsv.lib.php';

function scandir_real($dir) {
  if (!is_dir($dir))
  {
    return array();
  }
  $entries = array();
  foreach (scandir($dir) as $f) {
    if ( substr($f, 0, 1) != '.' ) {
      $entries[] = $f;
    }
  }
  return $entries;
}

function canonical($str) {
  return preg_replace("/[^a-z0-9]/", '', strtolower($str));
}

function printInfo($dir) {
  $info = json_decode( file_get_contents("$dir/info.json") );
  echo "<h1>$info->title v$info->version</h1>";
}

function validateDataset($dir) {
  $errors = array();

  $species = new parseCSV("$dir/species.csv");

  $species_canonical = array();
  foreach ($species->data as $spec) {
    $spec_canonical = array();
    foreach ($spec as $k => $v) {
      $spec_canonical[ canonical($k) ] = $v;
    }
    $species_canonical[] = $spec_canonical;
  }

  // Find all species images
  $img_species = array();
  foreach (scandir_real("$dir/species") as $img) {
    if ( preg_match('/^([^\.]+)\.[A-Za-z]+$/', $img, $matches) ) {
      $img_species[] = canonical($matches[1]);
    }
    else {
      $img_species[] = canonical($img);
    }
  }

  // Find all species in the CSV
  $csv_species = array();
  foreach ($species_canonical as $spec) {
    $csv_species[ canonical( $spec['name'] ) ] = true;
  }

  // Find all feature images
  $img_features = array();
  foreach (scandir_real("$dir/features") as $feature) {
    $img_features[canonical($feature)] = array();
    foreach (scandir_real("$dir/features/$feature") as $image) {
      $extension_dot = strrpos($image, '.');
      if ($extension_dot !== false) {
        $img_features[canonical($feature)][canonical(substr($image, 0, $extension_dot))] = true;
      }
      else {
        // no extension, whatever
        $img_features[canonical($feature)][canonical($image)] = true;
      }
    }
  }

  // Find all features which are present in the species
  $csv_features = array();
  foreach ($species_canonical as $spec) {
    foreach ($spec as $k => $vstr) {
      if ($k == 'name' || $k == 'displayname' || $k == 'description') continue;

      if ( empty($csv_features[$k]) )
      {
        $csv_features[$k] = array();
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
    $errors[] = "Feature with image folder doesn't have a column in CSV: <b>$feature</b>";
  }
  foreach (array_intersect_key($img_features, $csv_features) as $feature => $_)
  {
    foreach (array_diff_key($img_features[$feature], $csv_features[$feature]) as $value => $_) {
      $errors[] = "Feature image isn't used by any species: <b>$feature &rightarrow; $value</b>";
    }
  }

  // Validation: find species features which don't have images
  foreach (array_diff_key($csv_features, $img_features) as $feature => $_) {
    $errors[] = "Feature in CSV doesn't have image folder: <b>$feature</b>";
  }
  foreach (array_intersect_key($csv_features, $img_features) as $feature => $_)
  {
    foreach (array_diff_key($csv_features[$feature], $img_features[$feature]) as $value => $_) {
      $errors[] = "Feature value in CSV doesn't have an image: <b>$feature &rightarrow; $value</b>";
    }
  }

  // Validation: find species images which can't be matched to CSV rows
  $csv_species_with_images = array();
  foreach ($img_species as $img) {
    $original_image = $img;
    $has_image = false;
    for (; $img; $img = substr($img, 0, -1)) {
      if (array_key_exists($img, $csv_species)) {
        $csv_species_with_images[$img] = true;
        $has_image = true;
        break;
      }
    }
    if (!$has_image) {
      $errors[] = "Image couldn't be matched to a species: <b>$original_image</b>";
    }
  }

  // Validation: find CSV rows which didn't have any images matched to them
  foreach (array_diff_key($csv_species, $csv_species_with_images) as $spec => $_) {
    $errors[] = "Species has CSV row but no image: <b>$spec</b>";
  }

  return $errors;
}
