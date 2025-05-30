var marker;
var allMarkers = [];

//Initiates the map on the page
function initMap() {

    let lat = 60.7872;
    let lng = 10.6869;

    //Center on inquiry if full map button was clicked
    let coord = document.getElementById("centered").innerHTML;
    if (coord !== ";"){
        splitCoord = coord.split(";");
        lat = splitCoord[0];
        lng = splitCoord[1];
    }

    map = new google.maps.Map(document.getElementById("googlemap"), {
      center: { lat: parseFloat(lat), lng: parseFloat(lng) },
      zoom: 15,
    });

}


//Virtually click on all markers to trigger functions to display markers
var allCoords = document.getElementsByClassName("coord");
var allStatusesCheck = document.getElementById("allStatuses"); //"Alle henvendelser" checkbox
var allPlantsCheck = document.getElementById("allPlants");  //"Alle planter" checkbox
var statusCheckboxes = document.getElementsByClassName("statusClass"); //Every status checkbox
var plantCheckboxes = document.getElementsByClassName("plantClass"); //Every plant checkbox
window.addEventListener("load", () => {checkAllPlants(allPlantsCheck); clickCoords();}); //Initially load markers 

//Checks all the checkboxes on or off based on the "all" checkbox
function checkAllStatus(elem) {
    for(var i = 0; i < statusCheckboxes.length; i++){
        if(elem.checked){
            statusCheckboxes[i].checked = true;
        } else {
            statusCheckboxes[i].checked = false;
        }
    }
}
//Checks all the checkboxes on or off based on the "all" checkbox
function checkAllPlants(elem) {
    for(var i = 0; i < plantCheckboxes.length; i++){
        if(elem.checked){
            plantCheckboxes[i].checked = true;
        } else {
            plantCheckboxes[i].checked = false;
        }
    }
}

//Virtually clicks on all the coordinate elements 
function clickCoords(){
    //Status
    //Check if checkboxes should be checked or not depending on the "all" checkbox
    var foundUnchecked = false;
    for(var i = 0; i < statusCheckboxes.length; i++){
        if (!statusCheckboxes[i].checked){
            foundUnchecked = true;
        }
    }
    if (foundUnchecked) {
        allStatusesCheck.checked = false;
    } else {
        allStatusesCheck.checked = true;
    }

    //Plants
    //Check if checkboxes should be checked or not depending on the "all" checkbox
    var foundUnchecked = false;
    for(var i = 0; i < plantCheckboxes.length; i++){
        if (!plantCheckboxes[i].checked){
            foundUnchecked = true;
        }
    }
    if (foundUnchecked) {
        allPlantsCheck.checked = false;
    } else {
        allPlantsCheck.checked = true;
    }
   
    

    clearOverlays();
    for(var i = 0; i < allCoords.length; i++){
        allCoords[i].click();
    }
}

//Places a marker from an inquiry on the map
function placeMarker(status, lat, lng, name, date, id) {

    for (var i = 0; i < statusCheckboxes.length; i++){
        if ((statusCheckboxes[i].value === status && statusCheckboxes[i].checked)){
            for (var j = 0; j < plantCheckboxes.length; j++){
                if ((plantCheckboxes[j].value === name) && plantCheckboxes[j].checked){
                    newMarker(status, lat, lng, name, date, id);
                } 
            }
            var found = false;
            for (var k = 0; k < plantCheckboxes.length; k++){
                if (name === plantCheckboxes[k].value){
                    found = true;
                }
            }
            if (!found && document.getElementById("otherPlants").checked){
                newMarker(status, lat, lng, name, date, id);
            }
        }
    }
}

//Gets custom icons based on inquiry status
//https://prefinem.com/simple-icon-generator/
//Size 32x32, border 4
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

//Create a new marker
function newMarker(status, lat, lng, name, date, id) {
    markerIcon = getMarker(name, status)
    marker = new google.maps.Marker({
        position: {lat: parseFloat(lat), lng: parseFloat(lng)},
        map: map,
        title: name + " - " + date,
        icon: markerIcon,
    });  
    marker.addListener("click", () => {
        window.location.href = "henvendelser/"+id;
      });
    allMarkers.push(marker);
}

//Clear all markers 
function clearOverlays() {
    for (var i = 0; i < allMarkers.length; i++ ) {
      allMarkers[i].setMap(null);
    }
    allMarkers.length = 0;
  }