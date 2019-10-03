var pageIndex = 0;
var responses = [];

var orderOfPlots = [];

// Firebase database
var database = new Firebase("https://functiondesc.firebaseio.com/");

$(function() {
  if(getUrlParameter("debug") !== undefined) {
    console.log("debug");
    debug(getUrlParameter("debug"));
  }

  $('#description').bind('input propertychange', function() {
    checkCharacters();
  });

  orderOfPlots = produceOrder();
});

function produceOrder() {
  var array1 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
  var array2 = [20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39];
  var array3 = [40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59];

  // Shuffle the arrays
  array1 = shuffle(array1);
  array2 = shuffle(array2);
  array3 = shuffle(array3);

  // Return the first three elements of each array:
  var sixPlotsOrder = [array1[0], array1[1], array2[0], array2[1], array3[0], array3[1]];

  sixPlotsOrder = shuffle(sixPlotsOrder);

  return sixPlotsOrder;
}

// From: https://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array#6274398
function shuffle(array) {
    let counter = array.length;

    // While there are elements in the array
    while (counter > 0) {
        // Pick a random index
        let index = Math.floor(Math.random() * counter);

        // Decrease counter by 1
        counter--;

        // And swap the last element with it
        let temp = array[counter];
        array[counter] = array[index];
        array[index] = temp;
    }

    return array;
}

function nextPage() {
  if(getExperimentStage() === 1 && descriptionHasData()){
        saveDescriptionData();
        clearDescription();
  }

  pageIndex++;

  if(getExperimentStage() === 0) {
    hideShow("#page1", "#page2");
  }
  else if (getExperimentStage() == 1) {
    $("#instructions").hide();
    $("#canvasPage").fadeIn();
    disableContinueButton();

    // Hide the Textarea
    toggleDescriptionTextArea();

    // Create, show, and save graph
    showGraph("graph");

    // Update instrucions (which includes Starting a timer)
    updateSpecificInstructions(0, 10000); // ms. milliseconds
  }
  // Demographics page
  else if (getExperimentStage() == 2) {
    $("#demographicsPage").fadeIn();
    $("#page2").hide();
    $("#canvasPage").hide();
    disableContinueButton();
  }
  // Thank you page
  else if (getExperimentStage() == 3) {
    // Save and send all the information to the server
    sendData();

    // Hide the demographics" page and the continue button
    $("#demographicsPage").hide();
    $("#continueButtonPage").hide();
    disableContinueButton();

    // Show the final page
    $("#thankYouPage").fadeIn();
  }
} //end nextPage

// Returns the number of the current plot being shown
function getPlotNumber() {
  return pageIndex - 2;
}

function getExperimentStage() {
  var numberOfTrials = 6;

  if      (pageIndex <= 1) { return 0; } //instructions
  else if (pageIndex <= 1 + numberOfTrials) { return 1; } //experiment
  else if (pageIndex == 2 + numberOfTrials) { return 2; } //demographics
  else                     { return 3; } //thanks
}

function toggleInstructions() {
  $("#instructions").fadeToggle();
}

function clearDescription(){
  $("#description").val("");
}

function toggleDescriptionTextArea(){
  $("#description").toggle();
}

function getDescription(){
  return $('#description').val();
}

function getDescriptionLength(){
  return getDescription().length;
}

function descriptionHasData() {
  return getDescriptionLength() >= 1;
}

// Event triggered
function checkCharacters(){
  updateSpecificInstructionsOnDescriptionStage();

  if(descriptionHasData()) {
    enableContinueButton();
  }
  else{
    disableContinueButton();
  }
}

function saveDescriptionData() {
  toSave = {
    'pageIndex': pageIndex,
    'description': getDescription(),
    'points_shown': getDatapoints(),
    'plot_id': orderOfPlots[getPlotNumber()]
  }

  responses = responses.concat([toSave]);
}


// ######################### PLOT #########################

function updateSpecificInstructions(t, target) {
  var remaining = (target - t)/1000;

  $('#specificInstructions').text('Please watch the function below (' + remaining +' s.)')

  if(t < target){
      setTimeout(function(){updateSpecificInstructions(t+1000, target)}, 1000)
  }
  // If we reached the target time 't'
  else{
    hideGraph('#graph');

    updateSpecificInstructionsOnDescriptionStage();

    toggleDescriptionTextArea();
  }
}

function updateSpecificInstructionsOnDescriptionStage(){
  var description_length = "(" + getDescriptionLength() + " of 50 characters).";
  $('#specificInstructions').text('Please describe the previous graph ');
}

function hideGraph(elementId) {
  $(elementId).hide();
}

// Returns the datapoints to be shown in the graph.
function getDatapoints() {
  // Get the data associated to the current plot number, given the shuffling
  var y = list[orderOfPlots[getPlotNumber()]]

  return getXY(y);
}

function getXY(y) {
  var xy = [['x', 'y']];

  for(var i=0; i < y.length; i++) {
    xy.push([i, y[i]]);
  }

  return xy;
}

function showGraph(elementId) {
  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(drawChart);

  function drawChart() {
    var data = google.visualization.arrayToDataTable(getDatapoints());

    var options = {
      //hAxis: {title: 'Age', minValue: 0, maxValue: 15},
      //vAxis:{baselineColor: '#fff', gridlineColor: '#fff', textPosition: 'none'},
      hAxis:{textPosition: 'none', minValue: 0, maxValue: 100},
      vAxis:{textPosition: 'none', minValue: 0, maxValue: 1},
      //width: 800,
      height: 400,
      chartArea: {'width': '100%', 'height': '100%'},
      'tooltip' : {'trigger': 'none'},
      legend: 'none'
    };

    var chart = new google.visualization.ScatterChart(document.getElementById(elementId));

    chart.draw(data, options);
  }

  $('#graph').show()
}

// ######################### OTHERS #########################

// Check the demographics data when the form changes.
$("#demographics").change(function(){
  // If the data is full, then enable the Continue button
  var full = (getAge() !== undefined) && (getGender() !== undefined)

  if (full) {
    enableContinueButton();
  }
  else {
    disableContinueButton();
  }
});

// Returns the age on the demographics" form
function getAge() {
  return $("input[name=age]:checked", "#demographics").val();
}

// Returns the gender on the demographics" form
function getGender() {
  return $("input[name=gender]:checked", "#demographics").val();
}

// Saves the current data on the database
function sendData() {
  var now = $.now();

  database.push({
    //"userId": getUserId().toString(),
    //"sessionId": getSessionId().toString(),
    "now": now.toString(),
    "datetime": (new Date(now)).toString(),
    "gender": getGender().toString(),
    "age": getAge().toString(),
    "responses": responses
  });

  return now;
}

// ######################### UTILITIES #########################

function hideShow(hideSelector, showSelector){
  // Hides the "hideSelector" element(s) and shows (fades in) the "showSelector" element(s)
  $(hideSelector).hide();
  $(showSelector).fadeIn();
}

// Activate the Continue button
function enableContinueButton() {
  $("button[name=continue]").prop("disabled", false);
}

function disableContinueButton() {
  $("button[name=continue]").prop("disabled", true);
}

// ######################### DEBUG #########################

// From: https://stackoverflow.com/questions/19491336/get-url-parameter-jquery-or-how-to-get-query-string-values-in-js
// It returns the URL GET parameter indicated by (string) sParam
var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split("&"),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split("=");

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
}

function debug(value){
  for(var i=0; i<value; i++) {
    nextPage();
  }
}
