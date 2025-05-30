var btnLat = false;
var lat;
var lng;
var marker;
var image = [];

//Sends POST request with userform data
var form = document.getElementById("plantform");
form.onsubmit = function(event){

  //Checks if position is shared before submitting form
  if(!marker){
    //alert("Vi trenger posisjonen til planten først, enten del posisjonen din eller marker på kartet hvor planten er")
    document.getElementById("divPos").classList.add("invalid");
    return false;
  }

  var xhr = new XMLHttpRequest();
  var formData = new FormData(form);
  formData.set("files", JSON.stringify(image))
  //Open the request
  var url = window.location.href.split("/");
  xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/sendplant");
  xhr.setRequestHeader("Content-Type", "application/json");

  //Send the form data
  xhr.send(JSON.stringify(Object.fromEntries(formData)));

  xhr.onreadystatechange = function() {
    if (xhr.readyState == XMLHttpRequest.DONE) {
      //Reset form
      form.reset();

      var tabs = document.getElementsByClassName("tab");
      for(var i = 0; i < tabs.length; i++){
        tabs[i].style.display = "none"
      }
      var fTabs = document.getElementsByClassName("tabFinish");
      for(var i = 0; i < fTabs.length; i++){
        fTabs[i].style.display = "block"
      }
      document.getElementById("navButton").style.display = "none";
      document.getElementById("navCircle").style.display = "none";

      image = []
      //Removes name input if it is visible
      document.getElementById("namelabel").style.display = "none";
      document.getElementById("name").style.display = "none";
    }
  }
  //Fail the onsubmit to avoid page refreshing.
  return false; 
}

//Checks the value of the dropdown menu and lets user type in their own plant name
function checkDropdown(){
  var usersel = document.getElementById("listname").value;
  if(usersel.toUpperCase() !== "annet..".toUpperCase()){
    document.getElementById("namelabel").style.display = "none";
    document.getElementById("name").style.display = "none";
    document.getElementById("name").value = "";
  } else {
    document.getElementById("namelabel").style.display = "block";
    document.getElementById("name").style.display = "block";
  }
}

//Initiate google map and infowindow
let map, infoWindow;

//Initiates the map on the page
function initMap() {
  //Create new map and center on Gjøvik
  map = new google.maps.Map(document.getElementById("googlemap"), {
    center: { lat: 60.7872, lng: 10.6869 },
    zoom: 11,
  });
  infoWindow = new google.maps.InfoWindow();

  //Adds a click listener for placing new markers
  google.maps.event.addListener(map, "click", function(e) {
    placeMarker(e.latLng, map);
  });

  //Find a user"s location by clicking a button
  const locationButton = document.getElementById("myLocationButton");
  locationButton.addEventListener("click", () => {
    // Try HTML5 geolocation
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const pos = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          };

          //Centers the map and places a marker
          map.setCenter(pos);
          map.setZoom(16);
          placeMarker(pos, map)
        },
        () => {
          //Most likely no permission given
          handleLocationError(true, infoWindow, map.getCenter());
        }
      );
    } else {
      //Browser doesn"t support Geolocation
      handleLocationError(false, infoWindow, map.getCenter());
    }
  });
}

//If user has not given permission to share position or another error happens
function handleLocationError(browserHasGeolocation, infoWindow, pos) {
  infoWindow.setPosition(pos);
  infoWindow.setContent(
    browserHasGeolocation
      ? "En feil har oppstått, sjekk om du har gitt tilgang til å dele posisjonen din"
      : "Nettleseren din støtter ikke posisjonsdeling, vennligst plasser markøren på kartet manuelt"
  );
  infoWindow.open(map);
}

//Initiates map function
window.initMap = initMap;

//Places a new marker on map when clicked
function placeMarker(position, map) {
  //Delete previous marker
  if (marker){
    marker.setMap(null)
  }
  //Place new marker
  marker = new google.maps.Marker({
    position: position,
    map: map,
    draggable:true,
    title:"Dra meg rundt!"
});  
  map.panTo(position);
  map.setZoom(16);

  document.getElementById("lat").value = marker.getPosition().lat();
  document.getElementById("lng").value = marker.getPosition().lng();
}


//Get position of marker
function getMarker(){
  var mLat = marker.getPosition().lat();
  var mLng = marker.getPosition().lng();
  document.getElementById("markerPos").innerHTML = `Markør: ${mLat}, ${mLng}`
}

//Queue images for base64 encoding
function encodeImageFileAsURL(element) {
  image = []
  var file = element.files;
  
  document.getElementById("imgDiv").innerHTML = "";
  document.getElementById("imgPrev").src = "";


  //Calculate size limit
  var totalSize = 0;
  for (var i = 0; i < file.length; i++) {
    totalSize += file[i].size;
  }
  
  //Checks for files being too big 
  if(totalSize > (25 * 1048576)){
    alert("Filene er over 25 MB!");
    document.getElementById("files").value = null;
    return
  }
  
  if (file.length > 0) {
    loadNext(file, (file.length)-1)
  }
}

//Encode an image to base64
function loadNext(file, i) {
  var reader = new FileReader();
  reader.onloadend = function() {
    var base64result = reader.result.split(",")[1];
    image.push(base64result);

    //Present a preview of the images
    if(i == 0) {
      var locImg = document.getElementById("imgPrev");
      locImg.src = reader.result;
    } else {
      var newImg = document.createElement("img");
      newImg.src = reader.result;
      newImg.style.width = "150px";
      newImg.style.marginLeft = "10px";
      document.getElementById("imgDiv").appendChild(newImg);
    }

    if(i > 0){
      loadNext(file, i-1)
    }
  }
  reader.readAsDataURL(file[i]);
}

//Coords image
//Convert degrees, minutes and seconds data into single number data for google maps 
function DMStoDD(degrees, minutes, seconds, direction) {
  var dd = degrees + (minutes/60) + (seconds/3600);
  //If degrees are south or west
  if (direction == "S" || direction == "W") {
    dd = dd * -1;
  }
  return dd;
  }


//Extract coordinates from image
//https://awik.io/extract-gps-location-exif-data-photos-using-javascript/
function getCoords(imgData) {
    return EXIF.getData(imgData, function() {
      imgData = this;
      
      //Check if coordinates exists
      if (imgData.exifdata.GPSLatitude != null){
    
        //Latitude coordinates
        var latDeg = imgData.exifdata.GPSLatitude[0].numerator;
        var latMin = imgData.exifdata.GPSLatitude[1].numerator;
        var latSec = imgData.exifdata.GPSLatitude[2];
        var latDir = imgData.exifdata.GPSLatitudeRef;
        var lat = DMStoDD(latDeg, latMin, latSec, latDir);
    
        //Longitude coordinates
        var lngDeg = imgData.exifdata.GPSLongitude[0].numerator;
        var lngMin = imgData.exifdata.GPSLongitude[1].numerator;
        var lngSec = imgData.exifdata.GPSLongitude[2];
        var lngDir = imgData.exifdata.GPSLongitudeRef;
        var lng = DMStoDD(lngDeg, lngMin, lngSec, lngDir);
    
        //Place a marker 
        placeMarker({lat: lat, lng: lng}, map)
        document.getElementById("foundPos").innerHTML = "Vi hentet posisjonen din fra bildet du lastet opp. <br> Er dette riktig posisjon? <br><br> Hvis ikke, del posisjonen din med knappen nedenfor:";
      }
    });
}

//Opens the camera if clicked on a phone
function takePicBtn(){
  document.getElementById("files").setAttribute("capture","camera");
  document.getElementById("files").click();
}

//Opens files if clicked on a phone
function openPicBtn(){
  document.getElementById("files").removeAttribute("capture");
  document.getElementById("files").click();
}


//Tab system
//https://www.w3schools.com/howto/howto_js_tabs.asp
var currentTab = 0; 
showTab(currentTab); 

//The currently showing tab
function showTab(n) {
  var x = document.getElementsByClassName("tab");
  x[n].style.display = "grid";
  if (n == 0) {
    document.getElementById("prevBtn").style.display = "none";
  } else {
    document.getElementById("prevBtn").style.display = "inline";
  }
  if (n == (x.length - 1)) {
    document.getElementById("nextBtn").style.display = "none";
    document.getElementById("formSubmit").style.display = "block";
  } else {
    document.getElementById("nextBtn").style.display = "block";
    document.getElementById("formSubmit").style.display = "none";
  }
  fixStepIndicator(n)
}

//Next tab
function nextPrev(n) {
  var x = document.getElementsByClassName("tab");
  if (n == 1 && !validateForm()) return false;
  x[currentTab].style.display = "none";
  currentTab = currentTab + n;

  showTab(currentTab);
}

//Make sure all inputs are filled in correctly before proceeding
function validateForm() {
  valid = true;

  var listname = document.getElementById("listname");
  var name = document.getElementById("name");
  //var files = document.getElementById("files"); //Files must be added

  if (listname.value == "annet.." && name.value == ""){
    name.classList.add("invalid");
    valid = false;
  } else {
    name.classList.remove("invalid");
  }
  if (listname.value == ""){
    listname.classList.add("invalid");
    valid = false;
  } else {
    listname.classList.remove("invalid");
  }

  //If all inputs are correct, proceed
  if (valid) {
    getCoords(document.getElementById("imgPrev"));
    document.getElementsByClassName("step")[currentTab].className += " finish";
  }
  return valid;
}

//Updates step indicator to show what tab user is on
function fixStepIndicator(n) {
  var i, x = document.getElementsByClassName("step");
  for (i = 0; i < x.length; i++) {
    x[i].className = x[i].className.replace(" active", "");
  }
  x[n].className += " active";
}