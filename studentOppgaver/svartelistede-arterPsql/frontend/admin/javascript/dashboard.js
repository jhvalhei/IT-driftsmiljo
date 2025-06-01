
//Send a POST request to add plant
var formAdd = document.getElementById("addform");
formAdd.onsubmit = function(event){
    
    var xhr = new XMLHttpRequest();
    var formData = new FormData(formAdd);
    //Open the request
    var url = window.location.href.split("/");
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/addtolist");
    xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(Object.fromEntries(formData)));

  xhr.onreadystatechange = function() {
      if (xhr.readyState == XMLHttpRequest.DONE) {
          //Reset form
          formAdd.reset();
        }
    }
    return false;
}

//Send a POST request to remove a plant
var formRemove = document.getElementById("removeform");
formRemove.onsubmit = function(event){
    
    var xhr = new XMLHttpRequest();
    var formData = new FormData(formRemove);
    //Open the request
    var url = window.location.href.split("/");
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/removefromlist");
    xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(Object.fromEntries(formData)));

  xhr.onreadystatechange = function() {
      if (xhr.readyState == XMLHttpRequest.DONE) {
          //Reset form
          formRemove.reset();
        }
    }
    return false;
}