var gulp = require('gulp');
var browserSync = require('browser-sync').create();


// Configure the browserSync task
gulp.task('browserSync', function() {
    browserSync.init({
        server: {
            baseDir: 'bin/www'
        },
    })
})

// Dev task with browserSync
gulp.task('dev', ['browserSync'], function() {

    // Reloads the browser whenever HTML or JS files change
    gulp.watch('views/*.html', browserSync.reload);
    gulp.watch('routes/*.js', browserSync.reload);
});