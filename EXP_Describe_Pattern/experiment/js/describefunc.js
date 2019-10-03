////////////////////////////////////////////////////////////////////////
//            JS-CODE FOR GP-SMOOTHNESS-VARIANCE TRADE_OFF            //
//                       AUTHOR: ERIC SCHULZ                          //
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////
//VARIABLE CREATION
/////////////////////////////////////////////////////////
var inp=0;

//Initialize arrays
var N1 = [];
var Mu1 = [];
var Pos1 = [];
var index1 = 0;
var mu1=[];
var n1=generatesample();
var mychosen1=sample(n1);
var descollect=[];

////////////////////////////////////////////////////////////////
//load firebase with GPs
var ref = new Firebase("https://predictabilitydata.firebaseio.com/");
//var database = new Firebase("https://predictability.firebaseio.com/");

//retrieve GPs
var list=[];
ref.once('value', function(nameSnapshot) {
list=nameSnapshot.val();
return(list)
});

function download(text, name, type) {
    var a = document.createElement("a");
    var file = new Blob([text], {type: type});
    a.href = URL.createObjectURL(file);
    a.download = name;
    a.click();
}
jsonData = JSON.stringify(list);
download(jsonData, 'list.txt', 'text/plain');
////////////////////////////////////////////////////////////////

var specpresent=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
var comppresent=[20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39];
var judgepresent=shuffle(specpresent.concat(comppresent)).slice(0,5);
var order=shuffle([0,0,0,0,0,1,1,1,1,1]).slice(0,5);
////////////////////////////////////////////////////////////////

//Squaring without Math.pow
Array.prototype.contains = function(obj) {
    var i = this.length;
    while (i--) {
        if (this[i] == obj) {
            return true;
        }
    }
    return false;
}


//Function to randomly shuffle an array:
function shuffle(o)
{
    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
};

function sampleone(x)
{
  return(shuffle(x)[0])
}

function sample(n)
{

    var chosen = new Array(101)
  for (i = 0; i < 101; ++i)
  {
    chosen[i]=i;
  }

  return(shuffle(shuffle(chosen)).splice(0,n))
}

function sampleint(lower, upper, n)
{
  var diff=upper-lower;
    var chosen = new Array(diff);
  for (i = 0; i < diff; ++i)
  {
    chosen[i]=i+lower;
  }

  return(shuffle(shuffle(chosen)).splice(0,n))
}

/////////////////////////////////////////////////////////
//changes from one page to another
function clickStart(hide, show)
{
        document.getElementById(hide).style.display="none";
        document.getElementById(show).style.display = "block";
        window.scrollTo(0,0);
}

/////////////////////////////////////////////////////////
//function to create the stage where stimuli are presented
function makeStage(w, h, object)
{
  var stage = d3.select(object)
    .insert("center")
    .insert("svg")
    .attr("width",w)
    .attr("height",h);
        return stage;
}

//Create stage
var mystage0= makeStage(400,400, ".plot0")

//draws the points
function drawCircle(stage, cx, cy, mycolor)
{
  stage.insert("circle")
    .attr("cx", cx)
    .attr("cy", cy)
    .attr("r", 2)
    .style("fill",mycolor)
    .style("stroke",mycolor)
    .style("stroke-width","3px");
}

//Draws the marked points, I used ellipse as a hack to avoid class clashes
function drawEllipse(stage, ex, ey, mycolor)
{
  stage.insert("ellipse")
    .attr("cx", ex)
    .attr("cy", ey)
    .attr("rx", 2)
    .attr("ry", 2)
    .style("fill",mycolor)
    .style("stroke",mycolor)
    .style("stroke-width","3px");
}

//Update ellipse by slider
function updateEllipse(stage, ex, ey)
{
    stage.selectAll("ellipse").attr("cx", ex).attr("cy", ey);
}

//clears the points
function clearStimulus(stage)
{
  stage.selectAll("circle").remove();
}

//clears the ellipse
function clearEllipse(stage)
{
  stage.selectAll("ellipse").remove();
}


//scalings for plots using d3
var scalex = d3.scale.linear()
                    .domain([0, 10])
                    .range([10, 340]);
var scaley = d3.scale.linear()
                    .domain([0, 10])
                    .range([340, 10]);

//create x axis
function make_x_axis()
{
    return d3.svg.axis()
        .scale(scalex)
         .orient("bottom")
         .ticks(10)
}

//create y-axis
function make_y_axis()
{
    return d3.svg.axis()
        .scale(scaley)
        .orient("left")
        .ticks(10)
}

//Function to draw axes
function drawaxis(svg)
{
   svg.append("g")
        .attr("class", "grid")
        .attr("transform", "translate(0," + 350 + ")")
        .call(make_x_axis()
            .tickSize(-350, 0, 0)

        )

      svg.append("g")
        .attr("class", "grid")
        //.attr("transform", "translate("+16+",0)")
        .call(make_y_axis()
            .tickSize(-350, 0, 0)

        )

}

//Draw axes
drawaxis(mystage0)

/////////////////////////////////////////////////////////
function generatesample()
{
 return(100)
}

function generateinput(n)
{
 var inp = new Array(n+1);
 //create input space
 for(var j=0; j<n+1; j++) {
    inp[j]=j*10/n
  }
return(inp)
}

/////////////////////////////////////////////////////////
//prepare samples
function prepare()
{
  inp=generateinput(101);
  mu1=list[judgepresent[0]];
  n1=generatesample();
  mychosen1=sample(n1);

  for(var j=0; j<inp.length; j++)
  {
     drawCircle(mystage0,scalex(inp[j]),scaley(mu1[j]), "black");
  }
  clickStart('page3', 'page4')
}


/////////////////////////////////////////////////////////
//EXPERIMENT
/////////////////////////////////////////////////////////
//Experiment
function dotrial1()
{
  if (document.getElementById('description').value.length >30)
  {

    N1[index1]=n1;
    //Certainty1[index1]=CurrentValue;
    var description=document.getElementById('description').value;
    descollect=descollect.concat([description]);
    document.getElementById('description').value="Insert description here."
    Mu1[index1]=mu1;
    Pos1[index1]=mychosen1;

    if (index1 < 4)
    {
      index1=index1+1;
      clearStimulus(mystage0);
      inp=generateinput(101);
      mu1=list[judgepresent[index1]];
      n1=generatesample();
      mychosen1=sample(n1);
      for(var j=0; j<inp.length; j++)
      {
        if (mychosen1.contains(j))
        {
          drawCircle(mystage0,scalex(inp[j]),scaley(mu1[j]), "black");
        }

      }
      var insert ="Number of descriptions left: "+(5-index1)
      document.getElementById("remaining").innerHTML = insert;
    }
    else {
      clickStart('page4','page5');
    }
  }
  else{alert("Your description should at least contain 30 letters.")}
}


/////////////////////////////////////////////////////////
//EXPERIMENT PART 2: Comparisons
/////////////////////////////////////////////////////////
//SEND DATA
/////////////////////////////////////////////////////////

function senddata()
{
  var age=90;
  if (document.getElementById('age1').checked) {var  age = 20}
  if (document.getElementById('age2').checked) {var  age = 30}
  if (document.getElementById('age3').checked) {var  age = 40}
  if (document.getElementById('age4').checked) {var  age = 50}
  if (document.getElementById('age5').checked) {var  age = 60}
  if (document.getElementById('age6').checked) {var  age = 70}
  var gender=3;
  if (document.getElementById('gender1').checked) {var  gender = 1}
  if (document.getElementById('gender2').checked) {var  gender = 2}
  var desc="describe"

  database.push({N1: N1, Mu1: Mu1, Pos1: Pos1, desc: desc,
    descollect: descollect, judgepresent: judgepresent,
    order: order, age: age, gender: gender});

  clickStart('page6','page7');

}
/////////////////////////////////////////////////////////
//THE END
/////////////////////////////////////////////////////////
