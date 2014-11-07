<?php

require_once '../include/datasets.php';

$page_title = 'Upload';
function page_content() {
  global $dataset_id;
  ?>

<div class="page-header">
<h1>
  <?php
    if ($dataset_id <= 0) {
      echo 'Upload a new guide';
    }
    else {
      $dataset = get_dataset($dataset_id);
      $title = htmlspecialchars($dataset['title']);
      echo "Upload a new version of &ldquo;$title&rdquo;";
    }
  ?>
</h1>
</div>

<form role="form" action="?confirm" method="post" enctype="multipart/form-data">
  <div class="form-group">
    <label for="file-upload">Select your zip file</label>
    <input type="file" name="upload_zip" id="file-upload" />
  </div>
  <div class="form-group">
    <input class="btn btn-default" type="submit" value="Upload file" />
  </div>
  <input type="hidden" name="dataset_id" value="<?php echo $dataset_id; ?>" />
</form>

<p>The zip file should have a structure like the following:</p>

<ul>
  <li>
    <span><i class="glyphicon glyphicon-floppy-disk"></i> <code>myfile.zip</code></span>
    <ul>
      <li>
        <span><i class="glyphicon glyphicon-file"></i> <code>species.csv</code></span>
      </li>
      <li>
        <span><i class="glyphicon glyphicon-folder-open"></i> <code>features</code></span>
        <ul>
          <li>
            <span><i class="glyphicon glyphicon-folder-open"></i> <code>color</code></span>
            <ul>
              <li>
                <span><i class="glyphicon glyphicon-picture"></i> <code>red.png</code></span>
              </li>
              <li>
                <span><i class="glyphicon glyphicon-picture"></i> <code>blue.png</code></span>
              </li>
            </ul>
          </li>
          <li>
            <span><i class="glyphicon glyphicon-folder-open"></i> <code>size</code></span>
            <ul>
              <li>
                <span><i class="glyphicon glyphicon-picture"></i> <code>big.png</code></span>
              </li>
              <li>
                <span><i class="glyphicon glyphicon-picture"></i> <code>small.png</code></span>
              </li>
            </ul>
          </li>
        </ul>
      </li>
      <li>
        <span><i class="glyphicon glyphicon-folder-open"></i> <code>species</code></span>
        <ul>
          <li>
            <span><i class="glyphicon glyphicon-picture"></i> <code>dog.jpg</code></span>
          </li>
          <li>
            <span><i class="glyphicon glyphicon-picture"></i> <code>cat-tail.jpg</code></span>
          </li>
          <li>
            <span><i class="glyphicon glyphicon-picture"></i> <code>cat-claws.jpg</code></span>
          </li>
        </ul>
      </li>
    </ul>
  </li>
</ul>

<p>All images can be JPEG or PNG.</p>

<p>Your spreadsheet should look something like this:</p>

<table class="table table-bordered">
  <tr>
    <th>Name</th>
    <th>Color</th>
    <th>Size</th>
  </tr>
  <tr>
    <td>Dog</td>
    <td>Red</td>
    <td>Big</td>
  </tr>
  <tr>
    <td>Cat</td>
    <td>Red, Blue</td>
    <td>Small</td>
  </tr>
</table>

<p>Which will look like this when exported to <code>species.csv</code>:</p>

<pre>
Name,Color,Size
Dog,Red,Big
Cat,"Red, Blue",Small
</pre>

  <?php
}

include 'template.php';
