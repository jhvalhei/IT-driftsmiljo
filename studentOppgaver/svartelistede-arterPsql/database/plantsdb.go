package database

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"svarteliste/structs"
)

// Return all plant inquiries
func ListPlant() []structs.PlantInquiry {
	var inquiries []structs.PlantInquiry

	rows, err := DB.Query(`SELECT 
	id, listname, name, description, mail, 
	lat, lng, status, date, stringDate, private 
	FROM PlantInquiry`)
	if err != nil {
		log.Println(fmt.Errorf("ListPlant: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var inq structs.PlantInquiry
		if err := rows.Scan(&inq.Id, &inq.Listname, &inq.Name, &inq.Desc, &inq.Mail,
			&inq.Lat, &inq.Lng, &inq.Status, &inq.Date, &inq.StringDate, &inq.Private); err != nil {
			log.Println(fmt.Errorf("ListPlant: %v", err))
		}

		inq = ListPlantImages(inq)     // Retrieve images
		inq = ListPlantThumbnails(inq) // Retrieve thumbnails
		inq = ListPlantComments(inq)   // Retrieve comments

		inquiries = append(inquiries, inq)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("ListPlant: %v", err))
	}

	return inquiries
}

// Return all plant images for an inquiry
func ListPlantImages(inq structs.PlantInquiry) structs.PlantInquiry {
	rows, err := DB.Query("SELECT img FROM PlantImage WHERE id = ?", inq.Id)
	if err != nil {
		log.Println(fmt.Errorf("ListPlantImages: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var img string
		if err := rows.Scan(&img); err != nil {
			log.Println(fmt.Errorf("ListPlantImages: %v", err))
		}
		inq.ImgNames = append(inq.ImgNames, img)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("ListPlantImages: %v", err))
	}

	return inq
}

// Return all plant thumbnails for an inquiry
func ListPlantThumbnails(inq structs.PlantInquiry) structs.PlantInquiry {
	rows, err := DB.Query("SELECT thumbnail FROM PlantThumbnail WHERE id = ?", inq.Id)
	if err != nil {
		log.Println(fmt.Errorf("ListPlantThumbnails: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var thumb string
		if err := rows.Scan(&thumb); err != nil {
			log.Println(fmt.Errorf("ListPlantThumbnails: %v", err))
		}
		inq.Thumbnails = append(inq.Thumbnails, thumb)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("ListPlantThumbnails: %v", err))
	}

	return inq
}

// Return all plant comments for an inquiry
func ListPlantComments(inq structs.PlantInquiry) structs.PlantInquiry {
	rows, err := DB.Query(`SELECT 
	id, comment, date, stringDate, userId 
	FROM PlantComment WHERE id = ?`, inq.Id)
	if err != nil {
		log.Println(fmt.Errorf("ListPlantComments: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var com structs.Comment
		if err := rows.Scan(&com.Id, &com.Comment, &com.Date,
			&com.StringDate, &com.UserId); err != nil {
			log.Println(fmt.Errorf("ListPlantComments: %v", err))
		}
		inq.Comments = append(inq.Comments, com)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("ListPlantComments: %v", err))
	}

	return inq
}

// Return all plant names
func GetPlantList() []string {
	var plantList []string

	rows, err := DB.Query("SELECT name FROM PlantName WHERE name != 'Vet ikke' ORDER BY name") //Fetch 'Vet ikke' last
	if err != nil {
		log.Println(fmt.Errorf("GetPlantList: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var plant string
		if err := rows.Scan(&plant); err != nil {
			log.Println(fmt.Errorf("GetPlantList: %v", err))
		}
		plantList = append(plantList, plant)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("GetPlantList: %v", err))
	}
	plantList = append(plantList, "Vet ikke")

	return plantList
}

// Return all shapes
func GetShapeList() []string {
	var shapeList []string

	rows, err := DB.Query("SELECT shape FROM PlantShape")
	if err != nil {
		log.Println(fmt.Errorf("GetShapeList: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var shape string
		if err := rows.Scan(&shape); err != nil {
			log.Println(fmt.Errorf("GetShapeList: %v", err))
		}
		shapeList = append(shapeList, shape)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("GetShapeList: %v", err))
	}

	return shapeList
}

// Add a plant to the list of plants in userform
func AddToPlantList(plant string) {
	// Update DB with the new plant name
	_, err := DB.Exec("INSERT INTO PlantName (name) VALUES ($1)", plant)
	if err != nil {
		log.Println(fmt.Errorf("AddToPlantList: %v", err))
	}
}

// Removes a plant to the list of plants in userform
func RemoveFromPlantList(plant string) {
	// Update DB with the removed plant name
	_, err := DB.Exec("DELETE FROM PlantName WHERE name = ?", plant)
	if err != nil {
		log.Println(fmt.Errorf("RemoveFromPlantList: %v", err))
	}
}

// Returns name from list
func GetNameFromList(plant string) string {
	var name string
	if err := DB.QueryRow("SELECT name FROM PlantName WHERE name = ?", plant).Scan(&name); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			//If key does not exist, it is a custom name
			return "annet.."
		}
		log.Println(fmt.Errorf("GetNameFromList: %v", err))
		return ""
	}
	return name
}

// Insert new plant inquiry into DB
func InsertPlant(plant structs.PlantInquiry) {
	_, err := DB.Exec(`INSERT INTO 
		PlantInquiry (id, listname, name, description, mail, 
		lat, lng, status, date, stringDate, private) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		plant.Id, plant.Listname, plant.Name, plant.Desc, plant.Mail,
		plant.Lat, plant.Lng, plant.Status, plant.Date, plant.StringDate, plant.Private)
	if err != nil {
		log.Println(fmt.Errorf("InsertPlant: %v", err))
	}
	// Insert images
	InsertPlantImages(plant.Id, plant.ImgNames)
	// Insert thumbnials
	InsertPlantThumbnails(plant.Id, plant.Thumbnails)
	// Insert possible comments
	if len(plant.Comments) != 0 {
		for i := range plant.Comments {
			AddComment(plant.Comments[i])
		}
	}
}

// Insert new plant images into DB
func InsertPlantImages(id string, images []string) {
	for i := range images {
		_, err := DB.Exec("INSERT INTO PlantImage (id, img) VALUES (?, ?)", id, images[i])
		if err != nil {
			log.Println(fmt.Errorf("InsertPlantImages: %v", err))
		}
	}
}

// Insert new plant thumbnails into DB
func InsertPlantThumbnails(id string, thumbs []string) {
	for i := range thumbs {
		_, err := DB.Exec("INSERT INTO PlantThumbnail (id, thumbnail) VALUES (?, ?)", id, thumbs[i])
		if err != nil {
			log.Println(fmt.Errorf("InsertPlantThumbnails: %v", err))
		}
	}
}

// Insert a new plant comment into DB
func AddComment(comment structs.Comment) {
	_, err := DB.Exec("INSERT INTO PlantComment (id, comment, date, stringDate, userId) VALUES (?, ?, ?, ?, ?)",
		comment.Id, comment.Comment, comment.Date, comment.StringDate, comment.UserId)
	if err != nil {
		log.Println(fmt.Errorf("AddComment: %v", err))
	}
}

// Return all public and combated plants
func PublicListPlant() []structs.PlantInquiry {
	publiclist := []structs.PlantInquiry{}

	rows, err := DB.Query(`SELECT 
	id, listname, name, description, mail, 
	lat, lng, status, date, stringDate, private 
	FROM PlantInquiry WHERE status = 'combated' AND private = FALSE`)
	if err != nil {
		log.Println(fmt.Errorf("PublicListPlant: %v", err))
	}
	defer rows.Close()

	// Loop through rows
	for rows.Next() {
		var inq structs.PlantInquiry
		if err := rows.Scan(&inq.Id, &inq.Listname, &inq.Name, &inq.Desc, &inq.Mail,
			&inq.Lat, &inq.Lng, &inq.Status, &inq.Date, &inq.StringDate, &inq.Private); err != nil {
			log.Println(fmt.Errorf("PublicListPlant: %v", err))
		}

		inq = ListPlantImages(inq)     // Retrieve images
		inq = ListPlantThumbnails(inq) // Retrieve thumbnails
		inq = ListPlantComments(inq)   // Retrieve comments

		publiclist = append(publiclist, inq)
	}
	if err = rows.Err(); err != nil {
		log.Println(fmt.Errorf("PublicListPlant: %v", err))
	}

	return publiclist
}

// Return a single plant inquiry
func GetPlant(id string) *structs.PlantInquiry {
	var inq structs.PlantInquiry

	if err := DB.QueryRow(`SELECT id, listname, name, description, mail, 
		lat, lng, status, date, stringDate, private 
		FROM PlantInquiry 
		WHERE id = ?`,
		id).Scan(&inq.Id, &inq.Listname, &inq.Name, &inq.Desc, &inq.Mail,
		&inq.Lat, &inq.Lng, &inq.Status, &inq.Date, &inq.StringDate, &inq.Private); err != nil {
		log.Println(fmt.Errorf("GetPlant: %v", err))
	}

	inq = ListPlantImages(inq)     // Retrieve images
	inq = ListPlantThumbnails(inq) // Retrieve thumbnails
	inq = ListPlantComments(inq)   // Retrieve comments

	return &inq
}

// Check if id of plant inquiry exist
func DoesIdExist(id string) bool {
	var tmp string

	if err := DB.QueryRow("SELECT id FROM PlantInquiry WHERE id = ?", id).Scan(&tmp); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return false
		}
		log.Println(fmt.Errorf("DoesIdExist: %v", err))
		return false
	}

	return true
}

// Update DB with confirmed plant
func ConfirmPlant(id string) {
	_, err := DB.Exec("UPDATE PlantInquiry SET status = 'approved' WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("ConfirmPlant: %v", err))
	}
}

// Update DB with processing plant
func ProcessingPlant(id string) {
	_, err := DB.Exec("UPDATE PlantInquiry SET status = 'processing' WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("ProcessingPlant: %v", err))
	}
}

// Update DB with combated plant
func CombatedPlant(id string) {
	_, err := DB.Exec("UPDATE PlantInquiry SET status = 'combated' WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("CombatedPlant: %v", err))
	}
}

// Update DB with deleted plant
func DeletePlant(id string) {
	_, err := DB.Exec("UPDATE PlantInquiry SET status = 'deleted' WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("DeletePlant: %v", err))
	}
}

// Update DB and set an inquiry public
func SetPublic(id string) {
	_, err := DB.Exec("UPDATE PlantInquiry SET private = '0' WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("SetPublic: %v", err))
	}
}

// Update DB and set an inquiry private
func SetPrivate(id string) {
	_, err := DB.Exec("UPDATE PlantInquiry SET private = '1' WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("SetPrivate: %v", err))
	}
}

// Deletes and inserts a newly edited plant in db
func EditPlant(id string, plant structs.PlantInquiry) {
	_, err := DB.Exec("DELETE FROM PlantInquiry WHERE id = ?", id)
	if err != nil {
		log.Println(fmt.Errorf("EditPlant: %v", err))
	}

	// Insert new edited plant into DB
	InsertPlant(plant)
}

// Returns amount of inquiries for each status
func GetStatusLengths() structs.StatusLengths {
	new := 0
	approved := 0
	processing := 0
	combated := 0
	deleted := 0

	inquiries := ListPlant()
	for _, v := range inquiries {
		switch v.Status {
		case "new":
			new++
		case "approved":
			approved++
		case "processing":
			processing++
		case "combated":
			combated++
		case "deleted":
			deleted++
		default:
			println("Invalid status")
		}
	}

	return structs.StatusLengths{New: new, Approved: approved,
		Processing: processing, Combated: combated, Deleted: deleted}
}
