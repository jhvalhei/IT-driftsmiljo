package userform

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"math/rand"
	"net/http"
	"strings"
	"svarteliste/consts"
	"svarteliste/database"
	"svarteliste/structs"
	"time"
)

// Recieves a POST request from /userform and makes a struct out of it
func RecieveInquiry(w http.ResponseWriter, r *http.Request) {

	//Checks for correct method
	if r.Method != http.MethodPost {
		http.Error(w, "Method: "+r.Method+" is not supported", http.StatusBadRequest)
		return
	}

	// ================== 	Limit size	==================
	//Read the request body, but assign temporary variables to prevent body from changing
	buf, _ := ioutil.ReadAll(r.Body)
	tempBody := ioutil.NopCloser(bytes.NewBuffer(buf))
	readBody := ioutil.NopCloser(bytes.NewBuffer(buf))

	//Set a 35 MB limit to post request
	sizeLimit := int64(35 * consts.MB)
	_, err := ioutil.ReadAll(http.MaxBytesReader(nil, readBody, sizeLimit))
	if err != nil {
		println("Request body is too large for size limit: ", sizeLimit)
		return
	}
	r.Body = tempBody //Set body back to original body

	// ================== 	Decode request	==================
	//Creates a new struct made up from the userform
	plant := structs.PlantInquiry{}
	if err := json.NewDecoder(r.Body).Decode(&plant); err != nil {
		println("Error decoding struct: ", err.Error())
		return
	}
	plant.Status = "new"
	//Set name for plant based on user input
	if strings.EqualFold(plant.Listname, "annet..") {
		plant.Listname = plant.Name
	}

	plant.Date = time.Now()
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

	plant.StringDate = norDate.Replace(engDate)

	// ================== 	Decode image	==================
	//Convert uploaded image from encoded base64 to an actual image
	var imageSlice []string
	//Converts a string of base64 images to a slice of strings
	json.Unmarshal([]byte(plant.Files), &imageSlice)

	//Decodes the base64 string, excluding the header of the string
	for _, v := range imageSlice {
		plant.ImgNames = append(plant.ImgNames, "data:image/jpeg;charset=utf-8;base64,"+v)
	}
	//Insert first 2 images into thumbnail
	for i, v := range plant.ImgNames {
		if i < 2 {
			plant.Thumbnails = append(plant.Thumbnails, v)
		} else {
			break
		}
	}

	// ================== 	Set ID	==================
	//Generate an id for the inquiry
	rand.Seed(time.Now().UnixNano())
	id := CreateId(16)

	//Checks if id exists
	for database.DoesIdExist(id) {
		id = CreateId(16)
	}
	plant.Id = id

	plant.Private = true

	database.InsertPlant(plant)

}

// Create a string of random characters
func CreateId(length int) string {
	characters := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	var bytes = make([]byte, length)
	rand.Read(bytes)
	for k, v := range bytes {
		bytes[k] = characters[v%byte(len(characters))]
	}
	return string(bytes)
}
