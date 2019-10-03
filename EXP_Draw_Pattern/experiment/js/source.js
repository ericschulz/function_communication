var pageIndex = 0;
var responses = [];

var orderOfParticipants = [];
var pagesOrder = [];

// Google Charts
var chart;
var options;
var datapoints = [['x', 'y'], [0, 0]];

// Firebase database
var database = new Firebase("https://function-communication-exp-2.firebaseio.com/");

$(function() {
  if(getUrlParameter("debug") !== undefined) {
    console.log("debug");
    debug(getUrlParameter("debug"));
  }

  $('#description').bind('input propertychange', function() {
    checkNumberOfPoints();
  });

  // Produce the ordering of participants AND the indices to be shown
  produceOrderings();
});

function getDescriptionToShow(){
  //pageIndex is the page in which we currently are in the Experiment
  //the pagesOrder array determines the order to be checked
  var targetPageToShow = pagesOrder[getPlotNumber()];

  // We will only show the plots of the first participant of the shuffled array
  // of participants' IDs
  var targetPID = orderOfParticipants[0];
  return getTargetedDescription(targetPID, targetPageToShow);
}

// From the array of responses, returns the response associated to the specified
// PID and plot number
function getTargetedDescription(pid, page) {
  for (var i = 0; i < firstExperimentResponses.length; i++) {
    var response = firstExperimentResponses[i];

    if (response['pid'] == pid && response['page_index'] == page){
      return response;
    }
  }
  return 'error: not found';
}

function produceOrderings() {
  var chosenParticipants = [4,  3,  8,  14,  25,  10,  17];

  var pageIndices = [2, 3, 4, 5, 6, 7];

  orderOfParticipants = shuffle(chosenParticipants);
  pagesOrder = shuffle(pageIndices);
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
  if(getExperimentStage() === 1 && datapointsHasData()){
        savePageData();
        clearPage();
  }

  pageIndex++;

  if(getExperimentStage() === 0) {
    hideShow("#page1", "#page2");
  }
  else if (getExperimentStage() == 1) {
    $("#instructions").hide();
    $("#canvasPage").fadeIn();
    disableContinueButton();

    // Show new description
    $('#description').text(getDescriptionToShow()['description']);

    // Create, show, and save graph
    showGraph("graph");

    // Update instrucions (which includes Starting a timer)
    //updateSpecificInstructions(0, 10000); // ms. milliseconds
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

function clearPage(){
  // Clear points and refresh
  datapoints = [['x', 'y'], [0, 0]];
  updateChart();
}

function datapointsHasData(){
  return (datapoints.length > 1 + 5);
}

function checkNumberOfPoints(){
  if(datapointsHasData()) {
    enableContinueButton();
  }
  else{
    disableContinueButton();
  }
}

function savePageData() {
  toSave = {
    'pageIndex': pageIndex,
    'shownDescription': getDescriptionToShow(),
    'datapoints': datapoints
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
    $('#specificInstructions').text('Please draw the previous graph.');
    toggleDescriptionTextArea();
  }
}

function hideGraph(elementId) {
  $(elementId).hide();
}

function showGraph(elementId) {
  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(drawChart);

  function drawChart() {
    var data = google.visualization.arrayToDataTable(datapoints);

    options = {
      hAxis:{textPosition: 'none', minValue: 0, maxValue: 100},
      vAxis:{textPosition: 'none', minValue: 0, maxValue: 1},
      width: 750,
      height: 400,
      chartArea: {'width': '100%', 'height': '100%'},
      'tooltip' : {'trigger': 'none'},
      legend: 'none'
    };

    chart = new google.visualization.ScatterChart(document.getElementById(elementId));

    chart.draw(data, options);

    // onClick
    google.visualization.events.addListener(chart, 'click', onClickGraph);
  }

  $('#graph').show()
}

// Updates the points in the chart given the datapoints
function updateChart() {
  var data = google.visualization.arrayToDataTable(datapoints);
  chart.draw(data, options);
}

function onClickGraph(e) {
  // 'e' has the following structure:
  // Object { targetID: "chartarea", x: 596.5, y: 237.8000030517578 }
  // x and y are in pixels, where x=0, y=0 are at the top-left
  console.log(e);

  // Get the new point values, given the event's data
  var newPoint = fromPixelsToAxes(e['x'], e['y']);

  var index = getPointExists(newPoint);
  if(index == -1){
    // Add this point into the datapoints array
    console.log('point added: ' + newPoint);
    datapoints.push(newPoint);
  }
  else{
    //if the index is 0 or 1, then don't remove it
    if(index > 1){
      // Remove the point in index. 1 point only.
      datapoints.splice(index, 1);
    }
  }

  // Update the chart
  updateChart();

  // Update the continue button
  checkNumberOfPoints();
}

// Returns an index which indicates whether the point exists or not (and where)
function getPointExists(point){
  // Search for the point in the datapoints array
  // (Starts at i=1 because the first datapoint is ['x', 'y'])
  for(var i=1; i < datapoints.length; i++){
    if(equivalent(datapoints[i], point)){
      return i;
    }
  }

  // If no pair of points is found to be equivalent, then
  return -1;
}

// Are these two points equivalent?
function equivalent(point1, point2) {
  var range_x=100;
  var range_y=1;

  var ratio = 50;

  // Within range
  if(point1[0] < (point2[0] + range_x/ratio) && point1[0] > (point2[0] - range_x/ratio)){
    if(point1[1] < (point2[1] + range_y/ratio) && point1[1] > (point2[1] - range_y/ratio)){
      return true;
    }
  }

  return false;
}

function fromPixelsToAxes(pixelsX, pixelsY){
  // Given that width=750, and height=400.
  // And that x_range=[0, 100], and y_range=[0, 1]

  var newPointX = (pixelsX / 750) * (100 - 0);
  var newPointY = ((400 - pixelsY) / 400) * (1 - 0);

  newPointX = Math.round(newPointX);
  newPointY = Math.round(newPointY * 100) / 100;

  return [newPointX, newPointY];
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
