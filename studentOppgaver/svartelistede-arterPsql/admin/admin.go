package admin

import (
	"encoding/json"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"svarteliste/database"
	"svarteliste/structs"
	"svarteliste/userform"
	"time"
)

// Confirm an inquiry
func ConfirmInquiry(w http.ResponseWriter, r *http.Request) {

	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	plant := ""
	if err := json.NewDecoder(r.Body).Decode(&plant); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.ConfirmPlant(plant)
}

// Delete an inquiry
func DeleteInquiry(w http.ResponseWriter, r *http.Request) {

	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	plant := ""
	if err := json.NewDecoder(r.Body).Decode(&plant); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.DeletePlant(plant)
}

// Delete an inquiry
func CombatedInquiry(w http.ResponseWriter, r *http.Request) {

	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	plant := ""
	if err := json.NewDecoder(r.Body).Decode(&plant); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.CombatedPlant(plant)
}

// Edit an existing inquiry
func EditInquiry(w http.ResponseWriter, r *http.Request) {

	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	editedData := structs.EditInquiry{}
	if err := json.NewDecoder(r.Body).Decode(&editedData); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	plant := database.GetPlant(editedData.Id)

	plant.Desc = editedData.Desc
	plant.Listname = editedData.Listname
	database.EditPlant(plant.Id, *plant)
}

// Set inquiry to processing status
func ProcessInquiry(w http.ResponseWriter, r *http.Request) {
	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	var plantid string
	if err := json.NewDecoder(r.Body).Decode(&plantid); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.ProcessingPlant(plantid)
}

// Set inquiry to processing status
func RecoverInquiry(w http.ResponseWriter, r *http.Request) {
	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	var plantid string
	if err := json.NewDecoder(r.Body).Decode(&plantid); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.ConfirmPlant(plantid)
}

func MakeInquiry(w http.ResponseWriter, r *http.Request) {
	//TEST DATA ---------------------------------------------
	//Creates an inquiry and inserts into database, with random text and date
	//Used for quickly inserting an inquiry for testing

	//randomize a date
	rand.Seed(time.Now().UnixNano())
	min := time.Date(1970, 1, 0, 0, 0, 0, 0, time.UTC).Unix()
	max := time.Date(2070, 1, 0, 0, 0, 0, 0, time.UTC).Unix()
	delta := max - min

	sec := rand.Int63n(delta) + min
	ranDate := time.Unix(sec, 0)

	//Sets a numnber of random values
	temp := structs.PlantInquiry{
		Name:       "annet..",
		Listname:   userform.CreateId(18),
		Desc:       strings.NewReplacer("d", " ", "f", " ", "a", " ", "m", " ").Replace(userform.CreateId(200)),
		Mail:       "ompom@kmk.com",
		Lng:        "10.68" + strconv.Itoa(rand.Intn(99)) + "123",
		Lat:        "60.78" + strconv.Itoa(rand.Intn(99)) + "379",
		Id:         userform.CreateId(16),
		Date:       ranDate,
		StringDate: ranDate.Format("02. January 2006"),
		Status:     "new",
		Private:    true,
	}
	database.InsertPlant(temp)
	//TEST DATA ------------------------------------------------

}

// Add a comment to an inquiry
func AddComment(w http.ResponseWriter, r *http.Request) {

	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	newComment := structs.Comment{}
	if err := json.NewDecoder(r.Body).Decode(&newComment); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	//Get date
	newComment.Date = time.Now()
	engDate := time.Now().Format("02. January 2006")

	//Replace English months with Norwegian months
	norDate := strings.NewReplacer(
		"January", "januar",
		"February", "februar",
		"March", "mars",
		"April", "april",
		"May", "mai",
		"June", "juni",
		"July", "juli",
		"August", "august",
		"September", "september",
		"October", "oktober",
		"November", "november",
		"December", "desember")

	newComment.StringDate = norDate.Replace(engDate)
	database.AddComment(newComment)
}

//Adds a new plant to the list when selecting plants in userform
func AddToList(w http.ResponseWriter, r *http.Request) {
	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	newPlant := structs.ListPlantName{}
	if err := json.NewDecoder(r.Body).Decode(&newPlant); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.AddToPlantList(newPlant.Name)
}

//Removes a plant from the list of plants in userform
func RemoveFromList(w http.ResponseWriter, r *http.Request) {
	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	plant := structs.ListPlantName{}

	if err := json.NewDecoder(r.Body).Decode(&plant); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}
	database.RemoveFromPlantList(plant.Name)
}

//Sets an inquiry to private
func SetPrivate(w http.ResponseWriter, r *http.Request) {
	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	var plantid string
	if err := json.NewDecoder(r.Body).Decode(&plantid); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.SetPrivate(plantid)

}

//Sets an inquiry to public
func SetPublic(w http.ResponseWriter, r *http.Request) {
	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	//Decode struct
	var plantid string
	if err := json.NewDecoder(r.Body).Decode(&plantid); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}

	database.SetPublic(plantid)

}
