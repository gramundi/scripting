var pg = require('pg');
var connectionString = process.env.DATABASE_URL || 'postgres://wctdba:answrs1@localhost:5433/dev_140e';

var client = new pg.Client(connectionString);
client.connect();
var query = client.query('CREATE TABLE items(id SERIAL PRIMARY KEY, text VARCHAR(40) not null, complete BOOLEAN)');
query.on('end', function() { client.end(); });

