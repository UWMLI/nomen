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
        background-color: #AAA;
        padding-top: 6px;
        padding-left: 6px;
      }
      .row:last-child {
        padding-bottom: 6px;
      }
      .row-button {
        position: relative;
        display: inline;
      }
      .row-image {
        left: 0;
        top: 0;
        height: 200px;
        margin-right: 6px;
        border: 1px solid #444;
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
      var images =
        { 'Owl': 'http://upload.wikimedia.org/wikipedia/commons/f/f1/African_Scops_owl.jpg'
        , 'Parrot': 'http://upload.wikimedia.org/wikipedia/commons/8/81/Red_Lory_%28Eos_bornea%29-6.jpg'
        , 'Flycatcher': 'http://upload.wikimedia.org/wikipedia/commons/5/5d/Restless_flycatcher04.jpg'
        , 'Sunbittern': 'http://upload.wikimedia.org/wikipedia/commons/6/69/Stavenn_Eurypiga_helias_00.jpg'
        , 'Flamingo': 'http://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Caribbean_Flamingo2_%28Phoenicopterus_ruber%29_%280424%29_-_Relic38.jpg/760px-Caribbean_Flamingo2_%28Phoenicopterus_ruber%29_%280424%29_-_Relic38.jpg'
        };

      var makeRow = function(ids){
        var row = $('<div />', {'class': 'row'});
        ids.forEach(function(id){
          var button = $('<span />', {
            'class': 'row-button',
            'onmousedown': 'isDrag = false;',
            'onclick': 'if (!isDrag) console.log("'+id+'");',
          });
          var img = $('<img />', {'class': 'row-image', 'src': images[id]});
          var text = $('<div class="row-text">'+id+'</div>');
          button.append(img);
          button.append(text);
          row.append(button);
        });
        row.dragscrollable();
        $('.rows').append(row);
      };

      var deleteRow = function(){
        $('.row:last-child').remove();
      };

      $(document).ready(function(){
        makeRow(['Owl', 'Parrot', 'Flycatcher', 'Sunbittern', 'Flamingo']);
        makeRow(['Flamingo', 'Sunbittern', 'Owl', 'Parrot', 'Flycatcher']);
      });
    </script>
  </head>

  <body>

    <p>
      Resize your browser window so you can't see all the images, then
      click and drag to scroll horizontally.
    </p>

    <div class="rows">

    </div>

  </body>

</html>
