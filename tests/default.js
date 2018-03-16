process.env.NODE_ENV = 'test';

var fs = require('fs');
var path = require('path');
var config = JSON.parse(fs.readFileSync(path.normalize(__dirname + '/resources/config.json', 'utf8')));

const expect  = require('chai').expect;
const co      = require('co');
const fetch   = require('node-fetch');

const SERVER = config.urlBase;

let testObjects = config.objects;

for (let testObj of testObjects) {

let OBJ = testObj.obj;
let schema = testObj.schema;
let methods = testObj.methods;
let objectJSON = '';
let deleteObj = '';
let cont = 0;

for (let method of methods) {
/*
  * Test the /GET route
  */
if( method.name == 'GET'){
describe('TEST METHOD GET', function () {
    it('GET ' + OBJ + ' debe devolver todos los usuarios ver resultado', function(done) {
     co(function *() {
      var response = yield fetch(SERVER + OBJ);
      expect(response.status).to.be.equal(200);

      objectJSON = yield response.json();
      expect(objectJSON).to.be.an('Object');

      seeSIZE();
      validateJson();

      done();
    }).catch(function (err) {
        done(err);
    })
  });
});
}
/*
  * Test the /POST route
  */
if( method.name == 'POST'){
describe('TEST METHOD POST', function () {
    it('POST ' + OBJ + '/<parameter> debe añadir un nuevo usuario ver resultado', function(done) {
      co(function *() {
        const response = yield fetch(SERVER + OBJ, { 
          method: 'POST',
          body: JSON.stringify( schema ),
          headers: { 'Content-Type': 'application/json' }
        });
        expect(response.status).to.be.equal(200);

        objectJSON = yield response.json();
        expect(objectJSON).to.be.an('Object');

        seeObject();

        deleteObj = objectJSON;

        validateJson

        done();
      }).catch(function (err) {
        done(err);
      });
    });
});
}

/*
  * Test the /DELETE route
  */
if( method.name == 'DELETE'){
describe('TEST METHOD DELETE', function () {
    it('DELETE ' + OBJ + '/:id debe eliminar un usuario ver resultado', function(done) {
      co(function *() {

         const response = yield fetch(SERVER + OBJ +'/' + deleteObj.data[0].id, { 
          method: 'DELETE',
          body: JSON.stringify({}),
          headers: { 'Content-Type': 'application/json' }
        });

        expect(response.status).to.be.equal(200);

        objectJSON = yield response.json();
        expect(objectJSON).to.be.an('Object');

        seeObject();

        done();
      }).catch(function (err) {
        done(err);
      });
    });
});
}
/*
  * Test the validateJson response
  */
function validateJson(){
  var error = objectJSON.error;
  expect(error).to.be.a('Boolean');

  var array = objectJSON.data;
  expect(array).to.be.an('Array');

  for (let usr of array) {
    expect(usr).to.be.an('Object');
    expect(usr.id).to.be.a('Number');
    expect(usr.name).to.be.a('String');
    expect(usr.email).to.be.a('String');
    expect(usr.password).to.be.a('String');
  }
}


function seeObject(){
  console.log('');
  console.log('  <-- RESULTADO -->  ');
  console.log(objectJSON);
  console.log('');
}

function seeSIZE(){
  var array = objectJSON.data;
  expect(array).to.be.an('Array');

  for (let obj of array) {
    cont = cont + 1;
  }
  console.log('');
  console.log('  <-- RESULTADO -->  ');
  console.log('size:' + cont);
  console.log('');
  cont = 0;
}

};//for of method

};//for of object