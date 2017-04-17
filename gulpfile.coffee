gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
less       = require 'gulp-less'
rimraf     = require 'rimraf'
path       = require 'path'
fs         = require 'fs'
gutil      = require 'gulp-util'
sourcemaps = require 'gulp-sourcemaps'
install    = require 'gulp-install'
concat     = require 'gulp-concat'
autoReload = require 'gulp-auto-reload'
changed    = require 'gulp-changed'
rename     = require 'gulp-rename'
filter     = require 'gulp-filter'

#
#
# Options

outapp = './app'
outui  = outapp + '/ui'

paths =
    deploy:  './dist/'
    coffee:  './src/**/*.coffee'
    html:    './src/**/*.html'
    images:  './src/**/images/*.*'
    icons:   './src/icons'
    locales: './src/locales/*.json'
    media:   './src/media/*.*'
    less:    './src/ui/css/manifest.less'
    lessd:   './src/ui/css/**/*.less'
    css:     './src/**/*.css'
    fonts:   ['./src/**/*.eot', './src/**/*.svg',
              './src/**/*.ttf', './src/**/*.woff',
              './src/**/*.woff2']

# compile coffeescript
gulp.task 'coffee', ->
    gulp.src paths.coffee
        .pipe sourcemaps.init()
        .pipe coffee()
        .on 'error', (e) ->
            console.log e.toString()
            @emit 'end'
        .pipe sourcemaps.write()
#        .pipe changed outapp
        .pipe gulp.dest outapp


# reloader will inject <script> tag
htmlInject = -> gutil.noop()

# copy .html-files
gulp.task 'html', ->
    gulp.src paths.html
        .pipe htmlInject()
        .pipe gulp.dest outapp

# copy images
gulp.task 'locales', ->
    gulp.src paths.locales
        .pipe gulp.dest path.join outapp, 'locales'

# copy images
gulp.task 'media', ->
    gulp.src paths.media
        .pipe gulp.dest path.join outapp, 'media'

# copy images
gulp.task 'images', ->
    gulp.src paths.images
        .pipe gulp.dest outapp


gulp.task 'icons', ->
    nameMap =
        # Icons
        'icon_016.png': 'icon.png'
        'icon_032.png': 'icon@2.png'
        'icon_048.png': 'icon@3.png'
        'icon_128.png': 'icon@8.png'
        'icon_256.png': 'icon@16.png'
        'icon_512.png': 'icon@32.png'
        # Unread icon in tray (linux/windows)
        'icon-unread_016.png': 'icon-unread.png'
        'icon-unread_032.png': 'icon-unread@2x.png'
        'icon-unread_128.png': 'icon-unread@8x.png'
        # Read icon in tray (linux/windows)
        'icon-read_016.png': 'icon-read.png'
        'icon-read_032.png': 'icon-read@2x.png'
        'icon-read_128.png': 'icon-read@8x.png'
        # Unread icon in tray (Mac OS X)
        'osx-icon-unread-Template_016.png': 'osx-icon-unread-Template.png'
        'osx-icon-unread-Template_032.png': 'osx-icon-unread-Template@2x.png'
        # Read icon in tray (Mac OS X)
        'osx-icon-read-Template_016.png': 'osx-icon-read-Template.png'
        'osx-icon-read-Template_032.png': 'osx-icon-read-Template@2x.png'

    # gulp 4 requires async notification!
    new Promise (resolve, reject)->
        Object.keys(nameMap).forEach (name) ->
            gulp.src path.join paths.icons, name
                .pipe rename nameMap[name]
                .pipe gulp.dest path.join outapp, 'icons'
        resolve()

# compile less
gulp.task 'less', ->
    gulp.src paths.less
        .pipe sourcemaps.init()
        .pipe less()
        .on 'error', (e) ->
            console.log e
            @emit 'end'
        .pipe concat('ui/app.css')
        .pipe sourcemaps.write()
        .pipe gulp.dest outapp


# fontello/css
gulp.task 'fontello', ->
    gulp.src [paths.css, paths.fonts...]
        .pipe gulp.dest outapp


gulp.task 'reloader', ->
    # create an auto reload server instance
    reloader = autoReload()

    # copy the client side script
    reloader.script()
        .pipe gulp.dest outui

    # inject scripts in html
    htmlInject = reloader.inject

    # watch rebuilt stuff
    gulp.watch "#{outui}/**/*", reloader.onChange


gulp.task 'clean', (cb) ->
    rimraf outapp, cb

gulp.task 'default', ['coffee', 'html', 'images', 'media',
                      'locales', 'icons', 'less', 'fontello']

gulp.task 'watch', ['default', 'reloader', 'html'], ->
    # watch to rebuild
    sources = (v for k, v of paths)
    gulp.watch sources, ['default']