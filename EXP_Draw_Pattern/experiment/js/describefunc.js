////////////////////////////////////////////////////////////////
//load firebase with GPs
var ref = new Firebase("https://predictabilitydata.firebaseio.com/");

//retrieve GPs
var list=[];
ref.once('value', function(nameSnapshot) {
list=nameSnapshot.val();
return(list)
});
