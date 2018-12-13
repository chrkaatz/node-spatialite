const dbInterface = require('./db.js');

const db;
// init the db
console.log('Initialize the db');
dbInterface.init().then((initializedDB) => {
  console.log('db initialized');
  db = initializedDB;
  db.setup();
}).catch((err) => {
  console.error('error initializing the db', err.message);
});