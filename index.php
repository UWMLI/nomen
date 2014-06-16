<html>

  <head>
    <title>
      Field Guide Demo
    </title>

    <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, use r-scalable=0" name="viewport" />
    <meta name="viewport" content="width=device-width" />

    <script type="text/javascript" src="//code.jquery.com/jquery-1.11.0.min.js"></script>
    <script type="text/javascript" src="js/jquery.parse.min.js"></script>
    <script type="text/javascript" src="js/dragscrollable.js"></script>
    <style>
      .row {
        width: 100%;
        clear: left;
        white-space: nowrap;
        overflow-x: scroll;
        background-color: #AAA;
      }
      .row:last-child {
      }
      .row-button {
        position: relative;
        display: inline;
      }
      .row-image {
        height: 100px;
        border: 3px solid black;
      }
      .selected {
        border: 3px solid red;
      }
      .row-text {
        position: absolute;
        left: 3px;
        top: -89px;
        color: white;
        width: 88px;
        overflow-x: hidden;
        font-family: sans-serif;
        font-size: 13px;
        background-color: black;
        opacity: 0.7;
        padding: 6px;
      }
      #num-matching {
        padding-bottom: 10px;
        font-size: 20px;
      }
    </style>
    <script type="text/javascript">

      var toggleElement = function(element) {
        image = $(element).find('.row-image');
        if (image.hasClass('selected'))
          image.removeClass('selected');
        else
          image.addClass('selected');
        computeScores();
      };

      var makeRow = function(entries){
        var row = $('<div />', {'class': 'row'});
        entries.forEach(function(entry){
          var button = $('<span />', {
            'class': 'row-button',
            'onmousedown': 'isDrag = false;',
            'onclick': 'if (!isDrag) toggleElement(this);',
          });
          var img = $('<img />', {
            'class': 'row-image',
            'src': entry.image,
            'feature': entry.feature,
            'value': entry.value,
          });
          var text = $('<div class="row-text">'+entry.display+'</div>');
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
        $.getJSON('plantfeatures.json', function(json) {
          for (feature in json)
          {
            var values = json[feature];
            var row = [];
            values.forEach(function(value) {
              row.push({
                'display': value.split('_').join(' '),
                'image': 'plantfeatures/'+feature+'/'+feature+'-'+value+'.png',
                'feature': feature,
                'value': value,
              });
            });
            makeRow(row);
          }
        });
      });

      var selected = {};
      var computeSelected = function() {
        selected = {};
        $('.selected').each(function(index, img) {
          var feature = $(img).attr('feature');
          var value   = $(img).attr('value');
          if (!(selected[feature]))
            selected[feature] = [];
          selected[feature].push(value);
        });
      };

      var dataset = [];

      var computeScores = function() {
        computeSelected();
        var maxScore = 0;
        for (feature in selected)
        {
          maxScore++;
        }
        var viable = 0;
        dataset.forEach(function(row) {
          var name = row.Scientific_name;
          var score = 0;
          for (feature in selected)
          {
            var match = false;
            var user = selected[feature].map(function(specimenValue) {
              return specimenValue.toLowerCase().trim();
            });
            var specimen = row[feature].split(",").map(function(specimenValue) {
              return specimenValue.toLowerCase().trim();
            });
            user.forEach(function(userValue) {
              specimen.forEach(function(specimenValue) {
                if (userValue === specimenValue)
                  match = true;
              });
            });
            if (match)
              score++;
          }
          if (score >= maxScore * 0.9)
            viable++;
        });
        $('#num-matching').html(viable + ' likely matches.');
      };

      $.get('dataset.csv', function(str) {
        var parsed = $.parse(str);
        parsed.results.rows.forEach(function(row) {
          dataset.push(row);
        });

        $(document).ready(function() {
          computeScores();
        });
      });

    </script>
  </head>

  <body>

    <div id="num-matching">
    </div>

    <div class="rows">
    </div>

  </body>

</html>
