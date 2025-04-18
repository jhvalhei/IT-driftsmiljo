package admin

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"regexp"
	"strings"
	"svarteliste/database"
	"svarteliste/structs"

	"golang.org/x/crypto/bcrypt"
)

// Entry point handler for /runlogin endpoint
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodPost:
		// Retrive URL parts
		parts := strings.Split(r.URL.RequestURI(), "/")
		if parts[2] == "login" {
			handleLogin(w, r)
		} else if parts[2] == "signup" {
			handleSignup(w, r)
		}
	default:
		http.Error(w, "Method not supported.", http.StatusNotImplemented)
		return
	}
}

// Dedicated handler for login requests
func handleLogin(w http.ResponseWriter, r *http.Request) {
	user := structs.AdminUser{}
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		return
	}

	if err := validateUser(user); err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	http.Error(w, "Du er logget inn", http.StatusOK)
}

// Dedicated handler for sign up requests
func handleSignup(w http.ResponseWriter, r *http.Request) {
	newUser := structs.AdminNewUser{}
	if err := json.NewDecoder(r.Body).Decode(&newUser); err != nil {
		return
	}

	if err := validateNewUser(newUser); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	user := structs.AdminUser{}
	user.Uname = newUser.Uname
	user.Psw, _ = hashPassword(newUser.Psw)
	if err := database.CreateNewUser(user); err != nil {
		log.Println(err)
		http.Error(w, "Noe gikk galt", http.StatusInternalServerError)
	}

	http.Error(w, "Du er registrert som ny bruker", http.StatusOK)
}

// Validate a user for login
func validateUser(user structs.AdminUser) error {
	if temp, err := database.RetrieveSingleUser(user.Uname); err != nil {
		log.Println(err)
		return errors.New("feil brukernavn eller passord")
	} else { // user exists, check is the password matches
		if err := bcrypt.CompareHashAndPassword([]byte(temp.Psw), []byte(user.Psw)); err != nil {
			return errors.New("feil brukernavn eller passord")
		} else {
			return nil
		}
	}
}

// Validate a new user
func validateNewUser(newUser structs.AdminNewUser) error {
	if _, err := database.RetrieveSingleUser(newUser.Uname); err == nil {
		return errors.New("du kan ikke bruke dette brukernavnet")
	}

	if newUser.Psw != newUser.PswRept {
		return errors.New("passord er ikke lik gjentatt passord")
	}

	if !validateNewPassword(newUser.Psw) {
		return errors.New("passord må være minst 8 tegn, innholde tall, liten bokstav, og stor bokstav")
	}

	return nil
}

// Validate that the newly created password meets the requirements
func validateNewPassword(str string) bool {
	numeric := regexp.MustCompile(`\d`).MatchString(str)
	lowerCase := regexp.MustCompile(`[a-z]`).MatchString(str)
	UpperCase := regexp.MustCompile(`[A-Z]`).MatchString(str)
	longEnough := len(str) >= 8

	return numeric && lowerCase && UpperCase && longEnough
}

// Hash a password
func hashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}
