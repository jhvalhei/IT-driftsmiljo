var save = true;

//Initiates the map on the page
function initMap() {
    //Create new map with inquiry coordinates
    var lat = parseFloat(document.getElementById("lat").innerHTML)
    var lng = parseFloat(document.getElementById("lng").innerHTML)
    var name = document.getElementById("listname").innerHTML
    var status = document.getElementById("status").innerHTML

    map = new google.maps.Map(document.getElementById("googlemap"), {
      center: { lat: lat, lng: lng },
      zoom: 15,
    });

    //Place new marker
    marker = new google.maps.Marker({
        position: {lat: lat, lng: lng},
        map: map,
        title: name,
        icon: getMarker(name,status),
    });  
  
    //Adds a click listener for placing new markers
    google.maps.event.addListener(map, "click", function(e) {
      placeMarker(e.latLng, map); 
    });
}


  //Edit inquiry
  function editInquiry() {
    save = false;
    
    //Edit button
    document.getElementById("editBtn").style.display = "none"
    document.getElementById("saveBtn").style.display = "block"

    //Edit title
    document.getElementById("plantName").style.display = "none";
    document.getElementById("plantNameInp").style.display = "block";
    document.getElementById("plantNameInp").value = document.getElementById("plantName").innerHTML;
  
    //Edit description
    document.getElementById("plantDesc").style.display = "none";
    document.getElementById("plantDescInp").style.display = "block";
    document.getElementById("plantDescInp").value = document.getElementById("plantDesc").innerHTML.trim();
  
  }

  //Save inquiry
  var form = document.getElementById("formEdit");
  form.onsubmit = function(){
    save = true;
    
    //Edit button
    document.getElementById("editBtn").style.display = "block"
    document.getElementById("saveBtn").style.display = "none"

    //Edit title
    document.getElementById("plantName").style.display = "block";
    document.getElementById("plantNameInp").style.display = "none";
    document.getElementById("plantName").innerHTML = document.getElementById("plantNameInp").value;
  
    //Edit description
    document.getElementById("plantDesc").style.display = "block";
    document.getElementById("plantDescInp").style.display = "none";
    document.getElementById("plantDesc").innerHTML = document.getElementById("plantDescInp").value;  
    
    // -- Send POST request to change inquiry data -- 
    var xhr = new XMLHttpRequest();
    var formData = new FormData(form);
    //Open the request
    var url = window.location.href.split("/");
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/editinquiry");
    xhr.setRequestHeader("Content-Type", "application/json");

    formData.set("id", (document.getElementById("inquiryId").innerHTML));
    //Send the form data
    xhr.send(JSON.stringify(Object.fromEntries(formData)));
    
    //Prevent redirect
    return false; 
  }

  //POST request to add a comment
  var commentForm = document.getElementById("formComment");
  commentForm.onsubmit = function() {
    var xhr = new XMLHttpRequest();
    var formData = new FormData(commentForm);
    //Open the request
    var url = window.location.href.split("/");
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/addcomment");
    xhr.setRequestHeader("Content-Type", "application/json");

    formData.set("id", (document.getElementById("inquiryId").innerHTML));
    //Send the form data
    xhr.send(JSON.stringify(Object.fromEntries(formData)));
    
    xhr.onload = function(){
      window.location.reload();
    }

    //Prevent redirect
    return false; 
  }

  //Gives a warning about potentially unsaved changes when leaving the page
  window.onbeforeunload = function () {
    if (!save){
      return "Endringene dine er ikke lagret"; //Some modern browsers have their own message
    }
    return undefined;
  };

function getMarker(name, status) {
    
  var imgsrc = "/static/mapicons/";

  switch (status){
      case "new": 
          imgsrc += "red"; break;
      case "approved": 
          imgsrc += "yellow"; break;
      case "processing": 
          imgsrc += "blue"; break;
      case "combated": 
          imgsrc += "green"; break;
      case "deleted": 
          imgsrc += "grey"; break;
      default: 
          return "defaulterror.png";
  }

  imgsrc += "_";

  //Adds custom icons for the plants
  switch (name.toUpperCase()){
      case "KJEMPEBJØRNEKJEKS": 
          imgsrc += "circle"; break;
      case "KJEMPESPRINGFRØ": 
          imgsrc += "triangle"; break;
      case "PARKSLIREKNE": 
          imgsrc += "diamond"; break;
      case "SPANSK KJØRVEL": 
          imgsrc += "hex"; break;
      default: 
          //Vet ikke/annet
          imgsrc += "square"; break;
  }

  imgsrc += ".png";
  return imgsrc;
}

//Confirm and save an inquiry 
function approveInquiry() {

  var xhr = new XMLHttpRequest();

  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/confirminquiry");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(document.getElementById("inquiryId").innerHTML));

  //redirect back to inquiries
  var url = window.location.href.split("/");
  window.location.replace(url[0]+"//"+url[1]+url[2]+"/henvendelser");

  
  return false; 
}

//Initiate PDF creation
function processInquiry(){ 
  document.getElementById("showContact").style.display = "block";
  document.getElementById("showInquiry").style.display = "none";
}

//Generate a PDF
function generatepdf(){
  //Change textarea to normal text
  let labelP = document.getElementById("pdfLabelP");
  let commentP = document.getElementById("pdfCommentP");
  let label = document.getElementById("pdfLabel");
  let comment = document.getElementById("pdfComment");

  commentP.innerHTML = comment.value;
  label.style.display = "none";
  labelP.style.display = "block";
  //Set filename and allow external img src to be a Google map link 
  var opt = {
    filename:     document.getElementById("listname").innerHTML,
    html2canvas: { scale: 2, allowTaint: false, useCORS: true }
  };
  
  html2pdf().set(opt).from(document.getElementById("pdf")).save();
  
  //Generate pdf and proceed 2 seconds later
  setTimeout(proceedInquiry, 2000);
}

//Set status of inquriy to 'processing'
function proceedInquiry(){
  //Update status
  var xhr = new XMLHttpRequest();
  //Open the request
  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/processinquiry");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(document.getElementById("inquiryId").innerHTML));

  var url = window.location.href.split("/");
  window.location.replace(url[0]+"//"+url[1]+url[2]+"/henvendelser");

  return false;
}

//POST request to set inquiry status to 'combated'
function combatedInquiry(){ 
  var xhr = new XMLHttpRequest();
  //Open the request
  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/combatedinquiry");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(document.getElementById("inquiryId").innerHTML));

  var url = window.location.href.split("/");
  window.location.replace(url[0]+"//"+url[1]+url[2]+"/henvendelser");

  return false;
}

//POST request to delete an inquiry
function deleteInquiry() {
  if (!confirm("Er du sikker på at du vil slette denne henvendelsen?")){
    return
  }
  var xhr = new XMLHttpRequest();

  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/deleteinquiry");
  xhr.setRequestHeader("Content-Type", "application/json");

  
  //Send the form data
  xhr.send(JSON.stringify(document.getElementById("inquiryId").innerHTML));

  //redirect to inquiries
  var url = window.location.href.split("/");
  window.location.replace(url[0]+"//"+url[1]+url[2]+"/henvendelser");

  //Prevent redirect to post request url
  return false; 
}

//POST request to recover a deleted inquiry
function recoverInquiry(){ 
  let xhr = new XMLHttpRequest();
  //Open the request
  let url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/recoverinquiry");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(document.getElementById("inquiryId").innerHTML));

  url = window.location.href.split("/");
  window.location.replace(url[0]+"//"+url[1]+url[2]+"/henvendelser");

  return false;
}

//POST request to set privacy of an inquiry
function setPrivacy(privacy){
  let xhr = new XMLHttpRequest();
  //Open the request
  let url = window.location.href.split("/");
  if (privacy === "private"){
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/setprivate");
  } else {
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/setpublic");
  }
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(document.getElementById("inquiryId").innerHTML));

  window.location.reload();

  return false;
}

//Redirects user to the 'map' page 
function fullMapInquiry(){
  let url = window.location.href.split("/");
  url = url[0]+"//"+url[1]+url[2]+"/kart/"+document.getElementById("inquiryId").innerHTML;
  window.location.href = url;
}