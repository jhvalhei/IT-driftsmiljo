package structs

import "time"

//Information about a plant for POST request
type PlantInquiry struct {
	Listname   string `json:"listname"`
	Name       string `json:"name"`
	Desc       string `json:"desc"`
	Mail       string `json:"mail"`
	Lat        string `json:"lat"`
	Lng        string `json:"lng"`
	Files      string `json:"files"`
	Id         string
	ImgNames   []string
	Thumbnails []string
	Status     string //new, approved, processing, combated, deleted
	Date       time.Time
	StringDate string
	Comments   []Comment
	Private    bool
}

//Comment struct
type Comment struct {
	Comment    string `json:"comment"`
	Date       time.Time
	StringDate string
	Id         string `json:"id"`
	UserId     string `json:"userid"`
}

//Information that can be edited in an inquiry
type EditInquiry struct {
	Listname string `json:"listname"`
	Desc     string `json:"desc"`
	Id       string `json:"id"`
}

//Admin user
type AdminUser struct {
	Uname string `json:"uname"`
	Psw   string `json:"psw"`
}

//New admin user
type AdminNewUser struct {
	Uname   string `json:"uname"`
	Psw     string `json:"psw"`
	PswRept string `json:"pswRept"`
}

//Layout structs for html layouts
type ListInquiries struct {
	Single    []PlantInquiry
	FullList  []PlantInquiry
	StatusLen StatusLengths
	PlantList []string
}

//Data for map.html
type MapData struct {
	List          []PlantInquiry
	Plants        map[string]string
	CenteredPlant PlantInquiry
}

//Plants for userform
type ListPlantName struct {
	Name string `json:"name"`
}

//Contains lengths of all inquiries based on statuses
type StatusLengths struct {
	New        int
	Approved   int
	Processing int
	Combated   int
	Deleted    int
}
