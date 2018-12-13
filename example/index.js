const dbInterface = require('./db.js');

// init the db
console.log('Initialize the db');
dbInterface.init({ filename: 'db.sql' }).then(() => {
  console.log('db initialized');
  dbInterface.setup();
}).catch((err) => {
  console.error('error initializing the db', err.message);
});