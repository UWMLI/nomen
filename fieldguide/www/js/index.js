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
  var cutoffScore = maxScore * 0.9;

  var specimens = [];

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
      var specimen = row[feature].toString().split(",").map(function(specimenValue) {
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
    specimens.push({score: score, scientific: name});
  });

  specimens.sort(function(spec1, spec2) {
    return spec2.score - spec1.score; // sorts descending
  });
  viable = 0;
  for (var i = 0; i < specimens.length; i++)
  {
    if (specimens[i].score >= cutoffScore)
      viable++;
    else
      break;
  }

  var html = viable + ' likely match' + (viable == 1 ? '' : 'es') + '.'
  if (maxScore > 0)
  {
    html += ' Top choices:'
    html += '<ul>';
    specimens.slice(0, 10).forEach(function(specimen) {
      html += '<li>' + specimen.scientific + ' (' + specimen.score + ')</li>';
    });
    html += '</ul>';
  }
  $('#num-matching').html(html);
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

var app = {
  // Application Constructor
  initialize: function() {
    this.bindEvents();
  },
  // Bind Event Listeners
  //
  // Bind any events that are required on startup. Common events are:
  // 'load', 'deviceready', 'offline', and 'online'.
  bindEvents: function() {
    document.addEventListener('deviceready', this.onDeviceReady, false);
  },
  // deviceready Event Handler
  //
  // The scope of 'this' is the event. In order to call the 'receivedEvent'
  // function, we must explicitly call 'app.receivedEvent(...);'
  onDeviceReady: function() {
    document.write("Device  is ready.");
  },
};
