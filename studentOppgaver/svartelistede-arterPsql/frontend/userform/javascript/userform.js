var btnLat = false;
var lat;
var lng;
var marker;
var image = [];

//Send POST request with userform data
var form = document.getElementById("plantform");
form.onsubmit = function(event){
  //Checks if position is shared before submitting form
  if(!marker){
    alert("Vi trenger posisjonen til planten først, enten del posisjonen din eller marker på kartet hvor planten er")
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
      image = []
      //Removes name input if it is visible
      document.getElementById("namelabel").style.display = "none";
      document.getElementById("name").style.display = "none";
      alert("Din henvendelse er mottatt og vil bli sett på av oss i løpet av et par dager")
    }
  }
  //Fail the onsubmit to avoid page refreshing.
  return false; 
}

//Checks the value of the dropdown menu and lets user type in their own plant name
function checkDropdown(){
  var usersel = document.getElementById("listname").value;
  if(usersel !== "annet.."){
    document.getElementById("namelabel").style.display = "none";
    document.getElementById("name").style.display = "none";
    document.getElementById("name").required = false;
  } else {
    document.getElementById("namelabel").style.display = "block";
    document.getElementById("name").style.display = "block";
    document.getElementById("name").required = true;
  }
}

//Updates the validation checkbox if they enter email/phone
function contactinfoUpdate(){
  if(document.getElementById("mail").value !== ""){
    document.getElementById("checkformP").style.display = "block";
    document.getElementById("checkform").required = true;
  } else {
    document.getElementById("checkformP").style.display = "none";
    document.getElementById("checkform").required = false;
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
          //No permission given
          handleLocationError(true, infoWindow, map.getCenter());
        }
      );
    } else {
      //If browser does not support Geolocation
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
    if(i > 0){
      loadNext(file, i-1)
    }
  }
  reader.readAsDataURL(file[i]);
}s

//Convert degrees, minutes and seconds data into single number data for google maps 
function DMStoDD(degrees, minutes, seconds, direction) {
  var dd = degrees + (minutes/60) + (seconds/3600);
  //If degrees are south or west
  if (direction == "S" || direction == "W") {
    dd = dd * -1;
  }
  return dd;
  }
  
//Previews images when uploaded
function previewImage(){
  var preview = document.getElementById("imgPrev");
  var file    = document.getElementById("files").files[0];
  var reader  = new FileReader();

  reader.onloadend = function () {
    preview.src = reader.result;
  }
  
  if (file) {
    reader.readAsDataURL(file);
  } else {
    preview.src = "";
  }
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
      }
    });
}