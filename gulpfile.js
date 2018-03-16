var gulp = require('gulp');

var nock = require('nock');
var request = require('request');
var API_URL = 'https://localhost:3030';

gulp.task('test', function(){
	/*nock(API_URL)
  		.get('/')
  		.socketDelay(2000) // 2 seconds
  		.reply(200, '<html></html>')
  		*/


nock('should provide token in header', function (done) {
    nock(API_URL, {
        reqheaders: {
            'Content-Type': 'application/json'
        }
    })
        .get('/users')
        .reply(200, 'OK')
 
    mediaClient.musicList(function(error, response) {
        expect(response).to.eql('OK')
        done()
    })
 
})

});

 gulp.task('token', function(){
 	var User = function (token) {
    if (typeof token === 'undefined')
        throw new Error('You need to specify valid token for API request!');
    	this.token = token
	}
 })