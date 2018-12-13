const sqlite = require('sqlite3');

let db;

const query = "SELECT AsGeoJSON(Centroid(GeomFromText('POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))'))) AS geojson;";

module.exports = {
  init: (config) => {
    return new Promise((resolve, reject) => {
      db = new sqlite.Database(config.filename, (err) => {
        if (err) {
          reject(err);
        } else {
          db.loadExtension('mod_spatialite', (error) => {
            if (error) {
              reject(err);
            } else {
              resolve(db);
            }
          });
        }
      });
    });
  },
  setup: () => {
    db.serialize((err) => {
      if (err) {
        console.error(err);
      }
      db.each(query, (error, row) => {
        if (error) {
          console.error(error);
        } else {
          console.log(row.geojson);
        }
      });
    });
  },
  close: () => new Promise((resolve, reject) => {
    db.close((err) => {
      if (err) {
        reject(err);
      } else {
        resolve('DB closed');
      }
    });
  }),
};
