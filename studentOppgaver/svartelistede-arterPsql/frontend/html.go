package frontend

import (
	"embed"
	"net/http"
	"strings"
	"svarteliste/database"
	"svarteliste/structs"
	"text/template"
)

//go:embed *
var files embed.FS

// Html pages
var (
	userformFile       = userformParse("userform/userform.html")
	newUserformFile    = userformParse("userform/newuserform.html")
	adminLogin         = loginParse("admin/login.html")
	adminSignup        = loginParse("admin/signup.html")
	adminDashboard     = adminParse("admin/dashboard.html")
	adminInquiry       = adminParse("admin/inquiry.html")
	adminSingleInquiry = adminParse("admin/singleinquiry.html")
	adminMap           = adminParse("admin/map.html")
	adminPublicMap     = adminParse("admin/publicmap.html")
)

// Handler for /userform
func UserformHandler(w http.ResponseWriter, r *http.Request) {
	userformFile.Execute(w, "")
}
func NewUserformHandler(w http.ResponseWriter, r *http.Request) {
	newUserformFile.Execute(w, database.GetPlantList())
}

// Handler for /login
func AdminLoginHandler(w http.ResponseWriter, r *http.Request) {
	adminLogin.Execute(w, "")
}

// Handler for /signup
func AdminSignupHandler(w http.ResponseWriter, r *http.Request) {
	adminSignup.Execute(w, "")
}

// Handler for /dashboard
func AdminDashboardHandler(w http.ResponseWriter, r *http.Request) {
	adminDashboard.Execute(w, database.GetPlantList())
}

// Handler for /henvendelser
func AdminInquiryHandler(w http.ResponseWriter, r *http.Request) {

	//Split url to fetch id
	parts := strings.Split(r.URL.Path, "/")

	//Check if there is an id in the url
	if len(parts) == 3 && parts[2] != "" {
		if !database.DoesIdExist(parts[2]) {
			http.Error(w, "Her fant vi ingenting", http.StatusBadRequest)
			return
		}
		//Retrieve single inquiry
		var tempList []structs.PlantInquiry
		tempList = append(tempList, *database.GetPlant(parts[2]))
		p := structs.ListInquiries{
			Single: tempList,
		}
		adminSingleInquiry.Execute(w, p)
		return
	}

	plantList := database.GetPlantList()
	if len(plantList) > 0 {
		plantList = plantList[:len(plantList)-1]
	}
	//Retrieve list of inquiries
	p := structs.ListInquiries{
		FullList:  database.ListPlant(),
		StatusLen: database.GetStatusLengths(),
		PlantList: plantList,
	}
	adminInquiry.Execute(w, p)
}

// Handler for /kart
func AdminMapHandler(w http.ResponseWriter, r *http.Request) {

	//Split url to fetch id
	parts := strings.Split(r.URL.Path, "/")

	//Retrieve list of inquiries and stitch plants and icons together
	pList := database.GetPlantList()
	sList := database.GetShapeList() //
	sendMap := make(map[string]string)

	//Assign certain icons with certain plants
	sendMap[pList[0]] = sList[0]
	sendMap[pList[1]] = sList[4]
	sendMap[pList[2]] = sList[1]
	sendMap[pList[3]] = sList[2]
	sendMap[pList[4]] = sList[3]

	//Check if there is an id in the url
	if len(parts) == 3 && parts[2] != "" {
		if !database.DoesIdExist(parts[2]) {
			http.Error(w, "Her fant vi ingenting", http.StatusBadRequest)
			return
		}

		plant := database.GetPlant(parts[2])
		//Centers map on specific inquiry
		p := structs.MapData{
			List:          database.ListPlant(),
			Plants:        sendMap,
			CenteredPlant: *plant,
		}
		adminMap.Execute(w, p)
		return
	}

	p := structs.MapData{
		List:   database.ListPlant(),
		Plants: sendMap,
	}
	adminMap.Execute(w, p)
}

// Handler for /kart
func AdminPublicMapHandler(w http.ResponseWriter, r *http.Request) {

	//Send all public combated plants to map
	p := structs.MapData{
		List: database.PublicListPlant(),
	}
	adminPublicMap.Execute(w, p)
}

// Template for userform
func userformParse(file string) *template.Template {
	return template.Must(
		template.New("layoutform.html").ParseFS(files, "layoutform.html", file))
}

// Template for admin pages
func adminParse(file string) *template.Template {
	return template.Must(
		template.New("layoutadmin.html").ParseFS(files, "layoutadmin.html", file))
}

// Template for login pages
func loginParse(file string) *template.Template {
	return template.Must(
		template.New("layoutlogin.html").ParseFS(files, "layoutlogin.html", file))
}
