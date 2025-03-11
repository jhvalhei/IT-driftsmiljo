var marker;
var allMarkers = [];

//Initiates the map on the page
function initMap() {
    map = new google.maps.Map(document.getElementById("googlemap"), {
      center: { lat: 60.7872, lng: 10.6869 },
      zoom: 15,
    });

}


//Virtually click on all markers to trigger functions to display markers
var allCoords = document.getElementsByClassName("coord");
window.addEventListener("load", () => {clickCoords();}); //Initially load markers 

//Virtually clicks on all the coordinate elements 
function clickCoords(){
    clearOverlays();
    for(var i = 0; i < allCoords.length; i++){
        allCoords[i].click();
    }
}

//Places a marker from an inquiry on the map
function placeMarker(status, lat, lng, name, date) {
    newMarker(status, lat, lng, name, date);
}

//Create a new generic marker
function newMarker(status, lat, lng, name, date) {
    marker = new google.maps.Marker({
        position: {lat: parseFloat(lat), lng: parseFloat(lng)},
        map: map,
        title: name + " - " + date,
    });  
    allMarkers.push(marker);
}

//Clears all markers
function clearOverlays() {
    for (var i = 0; i < allMarkers.length; i++ ) {
      allMarkers[i].setMap(null);
    }
    allMarkers.length = 0;
  }