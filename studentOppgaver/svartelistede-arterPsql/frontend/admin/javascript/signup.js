var formSignup = document.getElementById("signupform");

//Send a POST request to signup
formSignup.onsubmit = function(event){
  var xhr = new XMLHttpRequest();
  var formData = new FormData(formSignup);

  //Open the request
  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/runlogin/signup");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(Object.fromEntries(formData)));

  xhr.onload = function() {
    alert(xhr.responseText)
  }

  xhr.onreadystatechange = function() {
    if (xhr.readyState == XMLHttpRequest.DONE) {
      //Reset form
      formSignup.reset();
    }
  }
  //Fail the onsubmit to avoid page refreshing.
  return false; 
}