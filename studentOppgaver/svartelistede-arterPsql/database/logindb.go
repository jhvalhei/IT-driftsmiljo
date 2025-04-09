package database

import (
	"database/sql"
	"errors"
	"fmt"
	"svarteliste/structs"
)

//Gets a user from database
func RetrieveSingleUser(uname string) (structs.AdminUser, error) {
	var user structs.AdminUser
	if err := DB.QueryRow("SELECT uname, psw FROM Users WHERE uname = ?",
		uname).Scan(&user.Uname, &user.Psw); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return user, fmt.Errorf("RetrieveSingleUser %q: unkown user", uname)
		}
		return user, fmt.Errorf("RetrieveSingleUser %q: %v", uname, err)
	}
	return user, nil
}

//Add user to database
func CreateNewUser(newUser structs.AdminUser) error {
	_, err := DB.Exec("INSERT INTO Users (uname, psw) VALUES (?, ?)", newUser.Uname, newUser.Psw)
	if err != nil {
		return fmt.Errorf("CreateNewUser: %v", err)
	}
	return nil
}

