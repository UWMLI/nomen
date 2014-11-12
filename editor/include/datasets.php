<?php

require_once 'db.php';
require_once 'util.php';

function get_datasets() {
  return DB::query('SELECT * FROM datasets WHERE user_id = %i', $_SESSION['user_id']);
}

function get_dataset($dataset_id) {
  return DB::queryFirstRow
    ( 'SELECT * FROM datasets WHERE user_id = %i AND id = %i LIMIT 1'
    , $_SESSION['user_id']
    , $dataset_id
    );
}

function publish_dataset($dataset_id, $title, $description, $upload_id) {
  DB::startTransaction();
  if ($dataset_id <= 0) {
    // New dataset
    DB::insert('datasets', array(
      'user_id' => $_SESSION['user_id'],
      'title' => $title,
      'description' => $description,
      'version' => 1,
    ));
    $dataset_id = DB::insertId();
  }
  else {
    // New version of existing dataset
    DB::update('datasets', array(
      'title' => $title,
      'description' => $description,
      'version' => DB::sqleval('version + 1'),
    ), 'id = %i AND user_id = %i', $dataset_id, $_SESSION['user_id']);
    if (DB::affectedRows() !== 1) {
      DB::rollback();
      return false;
    }
  }
  $dataset = get_dataset($dataset_id);
  $version = $dataset['version'];

  // Insert info.json into zip, save zip and extract to $dataset_id
  $zip_old = '../uploads/' . $upload_id . '.zip';
  $zip_new = '../www/datasets/' . $dataset_id . '.zip';
  $icon_out = '../www/datasets/' . $dataset_id;
  $extract_dir = '../www/datasets/' . $dataset_id;
  // First, add the info.json
  $zip = new ZipArchive;
  if ($zip->open($zip_old) !== TRUE) {
    DB::rollback();
    return false;
  }
  $icon_file = null;
  foreach (array('icon.png', 'icon.jpg', 'icon.jpeg') as $icon) {
    if ( $zip->statName($icon, ZipArchive::FL_NOCASE) ) {
      $icon_file = $icon;
    }
  }
  $zip_info = json_encode(array(
    'title' => $title,
    'description' => $description,
    'id' => DATASET_PREFIX . $dataset_id,
    'version' => $version,
    'author' => $_SESSION['email'],
    'icon' => $icon_file,
  ));
  $zip->addFromString('info.json', $zip_info);
  $zip->close();
  // Next, rename to new location
  rename($zip_old, $zip_new);
  // Finally, extract to folder
  $zip = new ZipArchive;
  if ($zip->open($zip_new) !== TRUE) {
    DB::rollback();
    return false;
  }
  rm_rf($extract_dir);
  mkdir($extract_dir);
  $zip->extractTo($extract_dir);
  // Save remote-view icon
  if ($icon_file) {
    $im_string = $zip->getFromName($icon_file);
    if ($icon_file === 'icon.png') {
      file_put_contents($icon_out . '.png', $im_string);
    }
    else {
      file_put_contents($icon_out . '.jpg', $im_string);
    }
  }
  $zip->close();
  // Save explicit JSON directory listings
  $pwd = getcwd();
  chdir($extract_dir);
  file_put_contents('features.json', json_encode( glob('features/*/*') ));
  file_put_contents('species.json', json_encode( glob('species/*') ));
  chdir($pwd);

  DB::commit();
  return true;
}

function delete_dataset($dataset_id) {
  DB::delete('datasets', "id = %i AND user_id = %i", $dataset_id, $_SESSION['user_id']);
  if (DB::affectedRows() != 1) return false;
  unlink('../www/datasets/' . $dataset_id . '.zip');
  rm_rf('../www/datasets/' . $dataset_id);
  rm_rf('../www/datasets/' . $dataset_id . '.png');
  rm_rf('../www/datasets/' . $dataset_id . '.jpg');
  return true;
}
