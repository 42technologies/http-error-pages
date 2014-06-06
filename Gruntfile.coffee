module.exports = (grunt) ->

  # load all grunt plugins defined in package.json
  require('load-grunt-tasks') grunt

  grunt.initConfig

    pkg: grunt.file.readJSON("package.json")

    concurrent:
      dev: [
        "jade:dev"
        "sass:dev"
        "coffee:dev"
        "copy"
      ]
      release: [
        "jade:release"
        "sass:release"
        "coffee:release"
        "copy"
      ]
      optimize: [
        "uglify"
        "newer:imagemin"
        "inline:release"
      ]

    connect:
      options:
        base: ["release"]
      dev:
        options:
          keepalive: false
      release:
        options:
          keepalive: true

    clean:
      dev: ["release"]
      release: ["release",]
      tmp: [ "release/tmp"]

    coffee:
      dev:
        files:
          "release/js/app.js": ["src/script/*.coffee"]
        options:
          sourceMap: true

      release:
        files:
          "release/tmp/app.js": ["src/script/*.coffee"]

    coffeelint:
      app: ['src/script/*.coffee']

    copy:
      js:
        files: [
          expand: true
          flatten: true
          src: ["src/script/**/*.js"]
          dest: "release/js/"
        ]

      assets:
        files: [
          expand: true
          flatten: true
          src: ["src/assets/**/*"]
          dest: "release/assets/"
        ]

    imagemin:
      release:
        files: [
          expand: true
          flatten: true
          src: ["src/assets/**/*.{png,jpg,gif}"]
          dest: "release/assets/"
        ]

    inline:
      release:
        src: ["release/**/*.html"]

    jade:
      options:
        data:
          title: "<%= pkg.name %>"
          author: "<%= pkg.author %>"
          description: "<%= pkg.description %>"
          version: "<%= pkg.version %>"

      dev:
        files: [
          expand: true
          cwd: "src"
          src: ["**/*.jade", '!**/_*.jade']
          dest: "release"
          ext: ".html"
        ]
        options:
          pretty: true

      release:
        files: [
          expand: true
          cwd: "src"
          src: ["**/*.jade", '!**/_*.jade']
          dest: "release"
          ext: ".html"
        ]

    sass:
      dev:
        files: [
          expand: true
          cwd: "src/sass"
          src: ["**/*.scss"]
          dest: "release/css"
          ext: ".css"
        ]
        options:
          linenos: true
          compress: false

      release:
        files: [
          expand: true
          cwd: "src/sass"
          src: ["**/*.scss"]
          dest: "release/css"
          ext: ".css"
        ]

    uglify:
      release:
        files: [
          expand: true
          cwd: "release/tmp"
          src: ["**/*.js"]
          dest: "release/js"
          ext: ".js"
        ]

    watch:
      jade:
        files: ["src/**/*.jade"]
        tasks: ["jade:dev"]

      sass:
        files: ["src/sass/**/*.sass"]
        tasks: ["sass:dev"]

      coffee:
        files: ["src/script/**/*.coffee"]
        tasks: ["newer:coffee:dev"]

      js:
        files: ["src/script/**/*.js"]
        tasks: ["newer:copy:script"]

      assets:
        files: ["src/assets/**/*"]
        tasks: ["newer:copy:assets"]

      grunt:
        files: ["Gruntfile.coffee", "package.json"]
        tasks: ["concurrent:dev"]

      options:
        spawn: false
        livereload: true

  # Start server in development mode
  grunt.registerTask "default", [
    "coffeelint"
    "clean"
    "concurrent:dev"
    "connect:dev"
    "watch"
  ]

  # Start server in preview mode
  grunt.registerTask "preview", [
    "clean:release"
    "clean:tmp"
    "concurrent:release"
    "concurrent:optimize"
    "clean:tmp"
    "inline:release"
    "connect:release"
  ]

  # Build optimized files
  grunt.registerTask "build", [
    "clean:release"
    "clean:tmp"
    "concurrent:release"
    "concurrent:optimize"
    "clean:tmp"
  ]
