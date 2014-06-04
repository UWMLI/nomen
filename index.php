<html>

  <head>
    <title>
      Field Guide Demo
    </title>
    <script type="text/javascript" src="//code.jquery.com/jquery-1.11.0.min.js"></script>
    <script type="text/javascript" src="js/dragscrollable.js"></script>
    <style>
      .row {
        width: 100%;
        clear: left;
        white-space: nowrap;
        overflow-x: hidden;
        background-color: #333;
        padding-left: 6px;
      }
      .row:first-child {
        padding-top: 5px;
      }
      .row:last-child {
        padding-bottom: 1px;
      }
      .row-button {
        position: relative;
        display: inline;
      }
      .row-button:last-child {
        padding-right: 6px;
      }
      .row-image {
        left: 0;
        top: 0;
        height: 200px;
        margin: 2px;
      }
      .row-text {
        position: absolute;
        left: 10;
        top: -180;
        color: white;
        font-family: sans-serif;
        background-color: #444;
        padding: 7px;
        border-radius: 3px;
      }
    </style>
    <script type="text/javascript">
      $(document).ready(function(){
        $('.row').dragscrollable({dragSelector:'*'});
        // todo: drag with the space between images
      });
    </script>
  </head>

  <body>

    <p>
      Resize your browser window so you can't see all the images, then
      click and drag to scroll horizontally.
    </p>

    <div class="rows">

      <div class="row">
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/f/f1/African_Scops_owl.jpg" />
          <div class="row-text">Owl</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/8/81/Red_Lory_%28Eos_bornea%29-6.jpg" />
          <div class="row-text">Parrot</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/5/5d/Restless_flycatcher04.jpg" />
          <div class="row-text">Flycatcher</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/6/69/Stavenn_Eurypiga_helias_00.jpg" />
          <div class="row-text">Sunbittern</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Caribbean_Flamingo2_%28Phoenicopterus_ruber%29_%280424%29_-_Relic38.jpg/760px-Caribbean_Flamingo2_%28Phoenicopterus_ruber%29_%280424%29_-_Relic38.jpg" />
          <div class="row-text">Flamingo</div>
        </span>
      </div>

      <div class="row">
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/5/5d/Restless_flycatcher04.jpg" />
          <div class="row-text">Flycatcher</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/6/69/Stavenn_Eurypiga_helias_00.jpg" />
          <div class="row-text">Sunbittern</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Caribbean_Flamingo2_%28Phoenicopterus_ruber%29_%280424%29_-_Relic38.jpg/760px-Caribbean_Flamingo2_%28Phoenicopterus_ruber%29_%280424%29_-_Relic38.jpg" />
          <div class="row-text">Flamingo</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/f/f1/African_Scops_owl.jpg" />
          <div class="row-text">Owl</div>
        </span>
        <span class="row-button">
          <img class="row-image" src="http://upload.wikimedia.org/wikipedia/commons/8/81/Red_Lory_%28Eos_bornea%29-6.jpg" />
          <div class="row-text">Parrot</div>
        </span>
      </div>

    </div>

  </body>

</html>
