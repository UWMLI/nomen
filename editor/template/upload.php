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
    <input class="btn btn-primary" type="submit" value="Upload file" />
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
        <span><i class="glyphicon glyphicon-picture"></i> <code>icon.png</code></span>
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

<ul>
  <li>
    The <code>icon</code> image should be small and square.
  </li>
  <li>
    <code>features</code> images should be small and somewhat square.
  </li>
  <li>
    <code>species</code> images can be of any size and shape.
  </li>
</ul>

<p>Your spreadsheet should look something like this:</p>

<table class="table table-bordered">
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Color</th>
    <th>Size</th>
  </tr>
  <tr>
    <td>Dog</td>
    <td>Canis lupus familiaris</td>
    <td>Red</td>
    <td>Big</td>
  </tr>
  <tr>
    <td>Cat</td>
    <td>Felis catus</td>
    <td>Red, Blue</td>
    <td>Small</td>
  </tr>
</table>

<p>Which will look like this when exported to <code>species.csv</code>:</p>

<pre>
Name,Description,Color,Size
Dog,Canis lupus familiaris,Red,Big
Cat,Felis catus,"Red, Blue",Small
</pre>

<ul>

<li><p>
  The <code>Name</code> is what gets displayed in the app's list of specimens,
  and also determines what image names to look for (see below). The
  <code>Description</code> is the text (or HTML) that is displayed below the
  full-screen photo when the user selects that specimen from the list.
  All the other fields are used to categorize specimens.
</p></li>

<li><p>
  In the above data, <code>Cat</code> has two values for <code>Color</code>,
  separated by commas, which means it shows up if you select either of those
  (or both).
</p></li>

<li><p>
  Filenames and spreadsheet values are not case sensitive, and when matching
  images to data, characters other than letters or numbers are ignored.
  Extra text may be added to the end of a specimen image name,
  so long as it doesn't end up forming the name of some other specimen.
</p></li>

<li>
  <p>
    For example, the specimen <code>Things + Stuff</code> could be linked to any of these images:
  </p>
  <p>
    <ul>
      <li><code>Things + Stuff.jpg</code></li>
      <li><code>things_stuff.jpeg</code></li>
      <li><code>THINGSSTUFF.PNG</code></li>
      <li><code>things + stuff - a cool image.png</code></li>
      <li><code>ThingsStuffFront.jpg</code></li>
    </ul>
  </p>
  <p>
    To ensure that a certain image is the primary one, name it with just the
    specimen name, nothing after it.
  </p>
</li>

</ul>



  <?php
}

include 'template.php';
