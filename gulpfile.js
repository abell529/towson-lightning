var cache       = require('gulp-cached');
var concat      = require('gulp-concat');
var csscomb     = require('gulp-csscomb');
// var cssnano     = require('gulp-cssnano');
var gulp        = require('gulp');
var header      = require('gulp-header');
var jshint      = require('gulp-jshint');
var less        = require('gulp-less');
var notify      = require('gulp-notify');
var plumber     = require('gulp-plumber');
var prettify    = require('gulp-jsbeautifier');
var rename      = require('gulp-rename');
var sourcemaps  = require('gulp-sourcemaps');
var uglify      = require('gulp-uglify');
var fileInclude = require('gulp-file-include');
var ngHtml2js   = require('gulp-ng-html2js');
var htmlmin     = require('gulp-htmlmin');
var bower       = require('gulp-bower');
var pkg         = require('./package.json');

// -------------------------------------------------------------------------------------------------
// Shared resource path locations
// -------------------------------------------------------------------------------------------------
// jsWatchMin - Files that will be watched then minified into a single Javascript file upon changes
// jsLint - Files that will be ran through the linter
// cssBootstrap - File that will be used to compile LESS to CSS
// cssWatchMin - Files that will be watched for changes then compiled upon changes
// -------------------------------------------------------------------------------------------------
  var srcPaths = {
    jsWatchMin:   ['scripts/**/*.js', '!scripts/vendor/**/*.js'],
    jsLint:       ['scripts/**/*.js', '!scripts/vendor/**/*.js'],
    overrides:  ['styles/overrides/overrides.less'],
    fonts:  ['styles/overrides/fonts/*.less'],
    components: ['styles/components/**/*.less','!styles/components/common.less','!styles/components/_base/**/*.less','!styles/components/_salesforce/**/*.less'],
    cleanCSS:     ['styles/**/*.less', '!styles/vendor/**/*.less'],
    cssWatchMin:  ['styles/**/*.less']
  };

// -------------------------------------------------------------------------------------------------
// Build resource path locations
// -------------------------------------------------------------------------------------------------
// js - Compiled/minified Javascript output location
// css - Compiled/minified CSS output location
// -------------------------------------------------------------------------------------------------
  var buildPaths = {
    js: 'src/staticresources/' + pkg.namespace + '/scripts',
    overrides: 'src/staticresources/' + pkg.namespace + '/styles',
    fonts: 'src/staticresources/' + pkg.namespace + '/styles/fonts',
    components: 'src/aura/'
  };

// -------------------------------------------------------------------------------------------------
// Error handler
// -------------------------------------------------------------------------------------------------
  var onError = function(err) {
    notify.onError({
      title:    'Gulp',
      subtitle: 'Failure!',
      message:  'Error: <%= error.message %>'
    })(err);
    this.emit('end');
  };

// -------------------------------------------------------------------------------------------------
// Header appended to all compiled files as a notice
// -------------------------------------------------------------------------------------------------
var compiledBanner = ['/**',
  ' * <%= pkg.name %> - <%= pkg.description %>',
  ' * @version <%= pkg.version %>',
  ' * @author <%= pkg.author %>',
  ' *',
  ' * COMPILED FILE DO NOT DIRECTLY EDIT',
  ' */',
  ''].join('\n');

// -------------------------------------------------------------------------------------------------
// CSS Tasks
// -------------------------------------------------------------------------------------------------

  // Compile LESS files into CSS
  // -----------------------------
  gulp.task('compileComponentCSS', ['cleanCSS'], function() {
    return gulp.src(srcPaths.components)
      .pipe(plumber({errorHandler: onError}))
      //.pipe(sourcemaps.init())
      .pipe(less())
      .pipe(header(compiledBanner, { pkg : pkg } ))
      // .pipe(cssnano({zindex: false}))
      //.pipe(sourcemaps.write('./'))
      .pipe(gulp.dest(buildPaths.components))
      .pipe(notify({
        title: 'Gulp',
        subtitle: 'Success',
        message: 'LESS compiled'
      }));
  });

  gulp.task('compileOverrideCSS', ['cleanCSS'], function() {
    return gulp.src(srcPaths.overrides)
      .pipe(plumber({errorHandler: onError}))
      //.pipe(sourcemaps.init())
      .pipe(less())
      .pipe(header(compiledBanner, { pkg : pkg } ))
      // .pipe(cssnano({zindex: false}))
      //.pipe(sourcemaps.write('./'))
      .pipe(gulp.dest(buildPaths.overrides))
      .pipe(notify({
        title: 'Gulp',
        subtitle: 'Success',
        message: 'LESS compiled'
      }));
  });

  gulp.task('compileFonts', ['cleanCSS'], function() {
    return gulp.src(srcPaths.fonts)
      .pipe(plumber({errorHandler: onError}))
       //.pipe(sourcemaps.init())
      .pipe(less())
      .pipe(header(compiledBanner, { pkg : pkg } ))
      // .pipe(cssnano({zindex: false}))
      //.pipe(sourcemaps.write('./'))
      .pipe(gulp.dest(buildPaths.fonts))
      .pipe(notify({
        title: 'Gulp',
        subtitle: 'Success',
        message: 'LESS compiled'
      }));
  });

  // Runs CSSComb and formats all custom LESS files.
  //
  // Configuration files:
  // /.csscomb.json
  //
  // For more information view:
  // http://csscomb.com
  // -----------------------------
  gulp.task('cleanCSS', function() {
    return gulp.src(srcPaths.cleanCSS, {base: './'})
      .pipe(plumber({errorHandler: onError}))
      .pipe(cache('csscomb'))
      .pipe(csscomb())
      .pipe(gulp.dest('./'));
  });

  // Build CSS tasks
  // -----------------------------
  gulp.task('buildCSS', ['compileComponentCSS','compileOverrideCSS','compileFonts']);

  // Runs JSLint and formats all custom JavaScript files except "vendor" files in the src/js/vendor directory.
  //
  // Configuration files:
  // JS Lint: /.jsintrc
  // JS Beautifer: /.jsbeautifyrc
  //
  // For more information view:
  // JS Lint: https://www.npmjs.org/package/gulp-jshint/
  // JS Beautifer: https://github.com/tarunc/gulp-jsbeautifier
  // -----------------------------
  gulp.task('cleanJS', function() {
    return gulp.src(srcPaths.jsLint, {base: './'})
    .pipe(plumber())
    .pipe(cache('cleanJS'))
    .pipe(jshint())
    .pipe(jshint.reporter('jshint-stylish'))
    .pipe(prettify({config: '.jsbeautifyrc'}))
    .pipe(gulp.dest('./'));
  });

  // Minifies all the JavaScript in the jsWatchMin paths
  // -----------------------------
  gulp.task('minifyJS', ['cleanJS'], function() {
    return gulp.src(srcPaths.jsWatchMin)
    .pipe(plumber())
    .pipe(concat(pkg.namespace + '.js'))
    .pipe(uglify({
      mangle: true,
      outSourceMap: true
    }))
    .pipe(header(compiledBanner, { pkg : pkg } ))
    .pipe(gulp.dest(buildPaths.js));
  });

  // Build JavaScript tasks
  // -----------------------------
  gulp.task('buildJS', ['minifyJS']);

// -------------------------------------------------------------------------------------------------
// Watch Tasks
// -------------------------------------------------------------------------------------------------
  gulp.task('watch', function() {
    gulp.watch([srcPaths.jsWatchMin, srcPaths.cssWatchMin], ['buildCSS','buildJS']);
  });

// -------------------------------------------------------------------------------------------------
// The default task (called when you run `gulp` from cli)
// -------------------------------------------------------------------------------------------------
  gulp.task('default', ['buildCSS','buildJS','watch']);


gulp.task('bower-install', function() {
  return bower();
});
