var pg=require('pg');
/*var conString = "postgres://YourUserName:YourPassword@localhost:5432/YourDatabase";*/
var conString = "postgres://wctdba:answrs1@localhost:5433/dev_140e";


var client = new pg.Client(conString);
client.connect();

//queries are queued and executed one after another once the connection becomes available
var x = 1000;

var query = client.query("SELECT * FROM umgr.users" );

//can stream row results back 1 at a time
query.on('row', function(row) {
  console.log(row);
});

//fired after last row is emitted
query.on('end', function() { 
  client.end();
});
