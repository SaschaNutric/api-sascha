var gulp = require('gulp');
const { exec } = require('child_process');

var modo = 'prod';
//name: "d7h3pnfqclegkn",

gulp.task('credenciales', function(){
  exec("bash $PWD/scripts/configdb.sh " + modo , (err, stdout, stderr) => {
  if (err) {
    console.log(`${err}`);
    return;
  }else if (stdout) {
    console.log(`stdout: ${stdout}`);
  }else {
    console.log(`stderr: ${stderr}`);  
  }

});
});

gulp.task('token', function(){


});