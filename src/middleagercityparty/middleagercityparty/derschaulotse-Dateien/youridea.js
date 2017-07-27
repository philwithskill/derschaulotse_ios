$(document).ready(function(){
	var form =$("form#form_idea"); 
	form.submit(function(event){ 
    event.preventDefault();
    
    var email = document.getElementById('inputEmail').value
    var idea = document.getElementById('textAreaIdea').value
    
    if(email == null || "" == email) {
    	return
    }
    
    yourIdea.shareIdea(email, idea);
      
    document.getElementById('inputEmail').value = "";
    document.getElementById('textAreaIdea').value = "";
    
    $("div#div_thanks").show();
      
   });
});


var yourIdea = {};

yourIdea.shareIdea = function(eMail, idea) {
	params = "email=" + eMail + "&idea=" + idea;
	request = new XMLHttpRequest();
	request.open("POST", "YourIdea", true);
	request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	request.setRequestHeader("Content-length", params.length);
	request.setRequestHeader("Connection", "close");
	request.send(params);
};


