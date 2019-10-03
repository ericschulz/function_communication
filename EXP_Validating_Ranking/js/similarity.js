////////////////////////////////////////////////////////////////////////
//                     JS-CODE FOR GP KERNEL MCMC                     //
//                       AUTHOR: ERIC SCHULZ                          //
//                    UCL LONDON,  FEBRUARY 2016                      //
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//INTIALIZE ARRAYS
////////////////////////////////////////////////////////////////////////
//Number of total trials
var ntrial = 49;
var trial=0;
var showcollect1=[];
var ratecollect=[];
var database = new Firebase('https://comparekernels.firebaseio.com/');

////////////////////////////////////////////////////////////////////////
//CREATE HELPER FUNCTIONS
////////////////////////////////////////////////////////////////////////
//hides page hide and shows page show
function clickStart(hide, show)
{
        document.getElementById(hide).style.display ='none' ;
        document.getElementById(show).style.display ='block';
        window.scrollTo(0,0);        
}

//changes inner HTML of div with ID=x to y
function change (x,y){
    document.getElementById(x).innerHTML=y;
}

//Hides div with id=x
function hide(x){
  document.getElementById(x).style.display='none';
}

//shows div with id=x
function show(x){
  document.getElementById(x).style.display='block';
}

//sets a value at the end to hidden id
function setvalue(x,y){
  document.getElementById(x).value = y;
}

function permute(o){ 
    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
};

var allcomp = [];
for (var i = 1; i <= 186; i++) {
   allcomp.push(i);
}
allcomp=permute(allcomp);

function camera(numb)
{
 var out='<input type="image" src="descs/plot'+numb+'.png"  width="500" height="600" border="0">';
  return(out);
}

numb1= allcomp[trial];
var ins1=camera(numb1);


change('p1', ins1);

var CurrentValue = "Please rate the quality.";
function markinput(value)
{
 //mark
 CurrentValue=value;
 //update by slider  
 $('#slidervalue').text(value);
}
markinput(CurrentValue);

function dotrial()
{
  if (CurrentValue == "Please rate the quality.")
  {
    alert("Please rate the quality.")    
  }else
  {
    showcollect1.push(numb1);
    ratecollect.push(CurrentValue);
    if (trial <ntrial)
    {
         trial=trial+1;
         numb1= allcomp[trial];
         ins1=camera(numb1);
         change('p1', ins1);
         var remainder ="Number of trials left: "+(50-trial);
         change("remain1", remainder);
         $(document).ready(function() {
          // var sliderex = document.getElementById('sliderex');
          $('#slider').slider({
              min: 0.0,
              max: 5.0,
              step: 1,
              value: 0.0,
              slide: function(event, ui) {
                  markinput(ui.value);
              }
          });
          });
         CurrentValue = "Please rate the quality.";
         markinput(CurrentValue);
    }
    else
    {
        alert("All blocks are over. You will be directed onto the next page once you click on 'ok'.")
        clickStart('page4','page5')
    }
  }
}

//////////////////////////////////////////////////////////////////////////
function senddata(){
    var age=90;
    if (document.getElementById('age1').checked) {var  age = 20}
    if (document.getElementById('age2').checked) {var  age = 30}
    if (document.getElementById('age3').checked) {var  age = 40}
    if (document.getElementById('age4').checked) {var  age = 50}

    var gender=3;
    if (document.getElementById('gender1').checked) {var  gender = 1}
    if (document.getElementById('gender2').checked) {var  gender = 2}
    var descsim=1;
    database.push({gender: gender, age: age, showcollect1: showcollect1, 
    	           ratecollect: ratecollect, descsim: descsim});
    clickStart('page5','page6');
}

$(document).ready(function() {
// var sliderex = document.getElementById('sliderex');
$('#slider').slider({
    min: 0.0,
    max: 5.0,
    step: 1,
    value: 0.0,
    slide: function(event, ui) {
        markinput(ui.value);
    }
});
})
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
