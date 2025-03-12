var formLogin = document.getElementById("loginform");

//Send a POST request to login
formLogin.onsubmit = function(event){
  var xhr = new XMLHttpRequest();
  var formData = new FormData(formLogin);

  //Open the request
  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/runlogin/login");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(Object.fromEntries(formData)));

  xhr.onload = function() {
    alert(xhr.responseText)
  }

  xhr.onreadystatechange = function() {
    if (xhr.readyState == XMLHttpRequest.DONE) {
      //alert(xhr.responseText)
      //Reset form
      formLogin.reset();
    }
  }
  //Fail the onsubmit to avoid page refreshing.
  return false
}