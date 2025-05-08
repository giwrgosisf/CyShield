import sqlite3 from 'sqlite3';
const db = new sqlite3.Database('./signal_users.db');
//  Create the database file if it doesn't exist
// and create the users table
// if it doesn't exist
// The database file is created in the same directory as the script
// The database file is named signal_users.db
// The users table is created with two columns: uuid and phone
// The uuid column is the primary key and is used to identify the user
// The phone column is used to store the user's phone number
// The uuid is generated when the user links their device to the server
// The phone number is entered by the user in the form
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      uuid TEXT PRIMARY KEY,
      phone TEXT
    )
  `);
});

export function addUser(uuid, phone) {
  return new Promise((resolve, reject) => {
    db.run(
      "INSERT OR IGNORE INTO users (uuid, phone) VALUES (?, ?)",
      [uuid, phone],
      function (err) {
        if (err) return reject(err);
        resolve();
      }
    );
  });
}
export function getAllUsers() {
  return new Promise((resolve, reject) => {
    db.all("SELECT * FROM users", (err, rows) => {
      if (err) return reject(err);
      resolve(rows);
    });
  });
}


