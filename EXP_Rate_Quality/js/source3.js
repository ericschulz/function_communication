////////////////////////////////////////////////////////////////////////
//                     JS-CODE FOR GP KERNEL MCMC                     //
//                       AUTHOR: ERIC SCHULZ                          //
//                    UCL LONDON,  FEBRUARY 2016                      //
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//INTIALIZE ARRAYS
////////////////////////////////////////////////////////////////////////
//Number of total trials
var showlist=sample(['ma', 'mb', 'mc', 'md', 'me', 'mf', 'mg', 'mh', 'mi', 'mj', 'mk', 'ml', 'mm', 'mn', 'mo', 'mp', 'mq', 'mr', 'ms', 'mt']);
var modlist=sample(['mix', 'com', 'sqe']);
var ntrial = showlist.length;
var trial=0;
var showthem=showlist[trial];
var chosen=-1;
var showcollect=[];
var modcollect=[];
//index for array tracking
var index=0;
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

function sample(o){ 
    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
};

function camera(focus, type)
{
 var out='<input type="image" src="https://dl.dropboxusercontent.com/u/4213788/comparison/'+focus+type+'.png"  width="250" height="250"';
 return(out);
}

function mymark(n){
    myboarder=['border="0">','border="0">', 'border="0">'];
    myboarder[n]='border="1">';
    var ins1=camera(showlist[index], modlist[0])+' onclick="mymark(0)" '+myboarder[0];
    var ins2=camera(showlist[index], modlist[1])+' onclick="mymark(1)" '+myboarder[1];
    var ins3=camera(showlist[index], modlist[2])+' onclick="mymark(2)" '+myboarder[2];
    change('p1', ins1);
    change('p2', ins2);
    change('p3', ins3);
    chosen=n;
}

var myboarder=['border="0">','border="0">', 'border="0">'];

var ins1=camera(showlist[index], modlist[0])+' onclick="mymark(0)" '+myboarder[0];
var ins2=camera(showlist[index], modlist[1])+' onclick="mymark(1)" '+myboarder[1];
var ins3=camera(showlist[index], modlist[2])+' onclick="mymark(2)" '+myboarder[2];


change('p1', ins1);
change('p2', ins2);
change('p3', ins3);



function dotrial()
{
    showcollect.push(showlist[index]);
    modcollect.push(modlist[chosen]);
    if (index <ntrial-1)
    {
         index=index+1;
         modlist=sample(modlist);
         myboarder=['border="0">','border="0">', 'border="0">'];
         ins1=camera(showlist[index], modlist[0])+' onclick="mymark(0)" '+myboarder[0];
         ins2=camera(showlist[index], modlist[1])+' onclick="mymark(1)" '+myboarder[1];
         ins3=camera(showlist[index], modlist[2])+' onclick="mymark(2)" '+myboarder[2];
         change('p1', ins1);
         change('p2', ins2);
         change('p3', ins3);
         var remainder ="Number of trials left: "+(20-index);
         change("remain1", remainder);
    }
    else
    {
        alert("All blocks are over. You will be directed onto the next page once you click on 'ok'.")
        clickStart('page4','page5')
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
      
    database.push({gender: gender, age: age, showcollect: showcollect, modcollect: modcollect});
    clickStart('page5','page6');

}
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////