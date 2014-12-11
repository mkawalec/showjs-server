var gulp       = require('gulp'),
    cjsx       = require('gulp-cjsx'),
    concat     = require('gulp-concat'),
    sourcemaps = require('gulp-sourcemaps'),
    less       = require('gulp-less'),
    browserify = require('gulp-browserify'),
    rename     = require('gulp-rename'),
    uglify     = require('gulp-uglify'),
    del        = require('del'),
    spawn      = require('child_process').spawn;

var paths = {
  frontend: ['interface/**/*.coffee'],
  styles: ['interface/**/*.less']
};

gulp.task('clean', function (cb) {
  del(['build'], cb);
});

// Compiles coffee to js
gulp.task('translate', ['clean'], function () {
  return gulp.src(paths.frontend)
    .pipe(sourcemaps.init())
    .pipe(cjsx({bare: true}))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('build/'));
});

gulp.task('main', ['translate'], function () {
  return gulp.src('build/main.js')
    .pipe(browserify())
    .pipe(rename('interface.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('compress', ['main'], function () {
  return gulp.src('static/interface.js')
    .pipe(uglify({mangle: false}))
    .pipe(rename('interface.min.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('styles', function () {
  return gulp.src(paths.styles)
    .pipe(less())
    .pipe(concat('style.css'))
    .pipe(gulp.dest('static/'));
});

gulp.task('watch', function () {
  gulp.watch(paths.frontend, ['main']);
  gulp.watch(paths.styles, ['styles']);
});

var server;
function spawnServer(cb) {
  if (server) {
    server.on('exit', function() {
      server = null;
      spawnServer(cb);
    });
    server.kill();
  } else {
    server = spawn('lsc', [ 'server' ], { stdio: 'inherit' });
    server.on('exit', function(code) {
      server = null;

      if (code && code !== 143) {
        setTimeout(spawnServer, 500);
      }
    });

    if (cb) {
      cb();
    }
  }
}

gulp.task('server.restart', spawnServer);
gulp.task('server', spawnServer);

gulp.task('server.watch', [ 'server' ], function() {
  gulp.watch([ 'server/**/*.ls' ], [ 'server.restart' ]);
});


gulp.task('default', [ 'server.watch', 'watch', 'main', 'styles' ]);
gulp.task('build', [ 'server.watch', 'compress', 'styles' ]);
