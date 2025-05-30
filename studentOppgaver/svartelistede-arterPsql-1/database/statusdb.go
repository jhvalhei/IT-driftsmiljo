package database

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
//    _ "github.com/lib/pq"

)

// MariaDB handle used by MariaDB functions throughout the program
var DB *sql.DB

// Checks for database connection
func DatabaseStatus() {
	err := DB.Ping()
	if err != nil {
		fmt.Println("The database seems to be down")
	} else {
		// Connect and check the server version
		var version string
		DB.QueryRow("SELECT VERSION()").Scan(&version)
		fmt.Println("The database is up Connected to: " + version)
	}
}
