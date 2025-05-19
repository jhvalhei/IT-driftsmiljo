// ===== TAB ====== //
//Opens a tab for a specific status inquiry
function openTab(evt, status) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("statusTab");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  //Reset all tabbutton active classes
  tablinks = document.getElementsByClassName("tabBtn");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  //Reset all tabcontent active classes 
  tabcontents = document.getElementsByClassName("tabContent");
  for (i = 0; i < tabcontents.length; i++) {
    tabcontents[i].className = tabcontents[i].className.replace(" currenttab", "");
  }
  //Set current tab 
  document.getElementById(status).style.display = "block";
  document.getElementById(status).className += " currenttab";
  evt.currentTarget.className += " active";
  setCookie("statusCookie", status);
  //Change sort if sort is set by initiating an onchange event
  document.getElementById("selSort").dispatchEvent(new Event('change'));
}

//Open tab based on if there is a cookie stored
if (readCookie("statusCookie") == "approved") {
  document.getElementById("approvedTab").click();
} else if (readCookie("statusCookie") == "processing"){
  document.getElementById("processingTab").click();
} else if (readCookie("statusCookie") == "combated"){
  document.getElementById("combatedTab").click();
}else if (readCookie("statusCookie") == "deleted"){
  document.getElementById("deletedTab").click();
} else {
  document.getElementById("newTab").click();
}

//------------------------
//TEST for making test inquiries
//Sends a POST request to create a test inquiry
function makeInq () {
    const xhr = new XMLHttpRequest();
    
    var url = window.location.href.split("/");
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/makeinquiry");
    xhr.send();

    xhr.onload = function(){
        window.location.reload();
    }
}
//------------------------



// ====== COOKIE ====== //
//Set tab cookie
function setCookie(cookiename, value) {
  document.cookie = cookiename + "=" + value + ";"
}

//Read cookie
function readCookie(cookiename) {
  let name = cookiename + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  //Go through cookies
  for(let i = 0; i < ca.length; i++) {
    let cookie = ca[i];
    while (cookie.charAt(0) == ' ') {
      cookie = cookie.substring(1);
    }
    if (cookie.indexOf(name) == 0) {
      return cookie.substring(name.length, cookie.length);
    }
  }
  return "";
}


// ====== SORT ====== //
if (readCookie("sortoption") != ""){
  document.getElementById("selSort").value = readCookie("sortoption");
  //Simulate onchange event when loading in
  document.getElementById("selSort").dispatchEvent(new Event('change'));
}

//Sort inquiries by name or date
function sortInq(evt){
  setCookie("sortoption", document.getElementById("selSort").value);
  
  var list, i, switching, b, shouldSwitch;

  tabcontent = document.getElementsByClassName("currenttab");
  list = tabcontent[0];
  
  //list = document.getElementById("ulNew");
  switching = true;
  //Get which sort to use
  let dir = evt.target.value; 

  //Loop until every element is alphabetically sorted
  while (switching) {
    switching = false;
    b = list.getElementsByTagName("LI");
    //Loop all LI items
    for (i = 0; i < (b.length - 1); i++) {
      // Start with no switch
      shouldSwitch = false;
      if (dir == "asc") {
        if (b[i].children[0].children[0].innerHTML.toLowerCase() > b[i + 1].children[0].children[0].innerHTML.toLowerCase()) {
          //If next item is lower alphabetically, break
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (b[i].children[0].children[0].innerHTML.toLowerCase() < b[i + 1].children[0].children[0].innerHTML.toLowerCase()) {
          //If alphabetically higher, break
          shouldSwitch = true;
          break;
        }
      } else if (dir == "dateasc"){
        let stringdateOne = stringToDate(b[i].children[0].children[1].innerHTML);
        let stringdateTwo = stringToDate(b[i+1].children[0].children[1].innerHTML);

         if (stringdateOne > stringdateTwo) {
          //If alphabetically lower, break
           shouldSwitch = true;
           break;
         }
      } else if (dir == "datedesc"){
        let stringdateOne = stringToDate(b[i].children[0].children[1].innerHTML)
        let stringdateTwo = stringToDate(b[i+1].children[0].children[1].innerHTML)
        
         if (stringdateOne < stringdateTwo) {
          //If alphabetically higher, break
           shouldSwitch = true;
           break;
         }
      }
    }
    if (shouldSwitch) {
      //If an item is out of order, swap the neighbouring item
      b[i].parentNode.insertBefore(b[i + 1], b[i]);
      switching = true;
    } 
  }
}


// ====== FILTER ====== // 
if (readCookie("filterplant") != ""){
  document.getElementById("selView").value = readCookie("filterplant");
  checkFilter();
}

//Filter based on plants
function checkFilter(){
  setCookie("filterplant", document.getElementById("selView").value)
  inquiries = document.getElementsByClassName("names");
  for (i = 0; i < inquiries.length; i++) {
    if(document.getElementById("selView").value.toLocaleLowerCase() == "all"){
      //All
      inquiries[i].parentNode.style.display = "grid";
      //implement 'other' option for filter
    } else if(document.getElementById("selView").value.toLocaleLowerCase() !== inquiries[i].innerHTML.toLocaleLowerCase()){
      //Remove everything except specific plant
      inquiries[i].parentNode.style.display = "none";
    } else {
      //Display specific plant
      inquiries[i].parentNode.style.display = "grid";
    }
  }
}

//Turn the stringdate into a date format for sorting
function stringToDate(strDate){
  
  let splitDate = strDate.split(" ");
  
  let month;
  switch(splitDate[1].toLocaleLowerCase()){
    case "januar": month="01";break;
    case "februar": month="02";break;
    case "mars": month="03";break;
    case "april": month="04";break;
    case "mai": month="05";break;
    case "juni": month="06";break;
    case "juli": month="07";break;
    case "august": month="08";break;
    case "september": month="09";break;
    case "oktober": month="10";break;
    case "november": month="11";break;
    case "desember": month="12";break;
  }
  
  let setDate = splitDate[2].substr(0,4)+"-"+month+"-"+splitDate[0].substr(0,2);
  let dateformat = new Date(setDate+"T12:00:00Z");
  return dateformat;
}



//Modal elements
var modal = document.getElementById("myModal");
var btn = document.getElementById("sortBtn");
var span = document.getElementsByClassName("close")[0];

//Open modal
btn.onclick = function() {
  modal.style.display = "block";
}

//Close modal
span.onclick = function() {
  modal.style.display = "none";
}

//Close modal when clicked out of focus
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}

//Show elements that were selected for the PDF
function selectInquiries(){
  let cbList = document.getElementsByClassName("checkboxLabel");
  for(let i = 0; i < cbList.length; i++){
    cbList[i].style.display = "block";
  }
  document.getElementById("createPdfBtn").style.display = "block";
  document.getElementById("cancelPdfBtn").style.display = "block";
  document.getElementById("selectInqBtn").style.display = "none";
}

//Cancel creating a pdf
function cancelSelect(){
  //Remove checkboxes
  let cbList = document.getElementsByClassName("checkboxLabel");
  for(let i = 0; i < cbList.length; i++){
    cbList[i].style.display = "none";
  }
  //Remove checks if cancel
  cb = document.getElementsByClassName("checkboxInquiry");
  for(let i = 0; i < cb.length; i++){
    if(cb[i].checked){
      cb[i].checked = false;
    }
  }
  
  document.getElementById("createPdfBtn").style.display = "none";
  document.getElementById("cancelPdfBtn").style.display = "none";
  document.getElementById("selectInqBtn").style.display = "block";
}

var checkedList = [];

//Readies and formats the page for generating the PDF
function createPDF(){
  //Hide current site and only show the PDF inquiries 
  document.getElementById("inquiryContainer").style.display = "none";
  document.getElementById("pdfContainer").style.display = "block";


  //Get all the checked inquiries
  cb = document.getElementsByClassName("checkboxInquiry");
  for(let i = 0; i < cb.length; i++){
    if(cb[i].checked){
      checkedList.push(cb[i].id);
    }
  }

  let lastElem;
  //Only show the marked inquiries
  let pdfPrint = document.getElementsByClassName("pdfPrint");
  for(let i = 0; i < pdfPrint.length; i++){
    if(checkedList.includes(pdfPrint[i].id)){
      pdfPrint[i].style.display = "grid";
      pdfPrint[i].className += " html2pdf__page-break"; //Line break for the PDF tool
      lastElem = pdfPrint[i];
    }
  }
  //Remove an empty page break
  lastElem.classList.remove("html2pdf__page-break");
}

//generates the pdf
function generatepdf(){
  //Hide button
  document.getElementById("generateBtn").style.display = "none";

  let label = document.getElementsByClassName("pdfLabel");
  let labelP = document.getElementsByClassName("pdfLabelP");
  for(let i = 0; i < label.length; i++){
    label[i].style.display = "none";
    labelP[i].style.display = "block";
    labelP[i].innerHTML = label[i].value;
  }

  //Set filename and allow external img src to be a Google map link 
  var opt = {
    filename:     "allpdf",
    html2canvas: { scale: 2, allowTaint: false, useCORS: true }
  };
  
  html2pdf().set(opt).from(document.getElementById("pdfPage")).save();

  setTimeout(proceedInuqiries, 2000);
}

//After the PDF is generated, change the status of the inquiries to 'processing'
function proceedInuqiries(){
  for(let i = 0; i < checkedList.length; i++){

    //Update status
    var xhr = new XMLHttpRequest();
    //Open the request
    var url = window.location.href.split("/");
    xhr.open("POST",url[0]+"//"+url[1]+url[2]+"/processinquiry");
    xhr.setRequestHeader("Content-Type", "application/json");
    
    //Send the form data
    xhr.send(JSON.stringify(checkedList[i]));
    
    var url = window.location.href.split("/");
    window.location.replace(url[0]+"//"+url[1]+url[2]+"/henvendelser");
  }
    
  return false;
}