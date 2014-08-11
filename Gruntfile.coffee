module.exports = (grunt)->
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-karma')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-bumpx')

  grunt.initConfig(
    pkg:
      grunt.file.readJSON('package.json')
    clean:
      dist: [
        'dist'
        'src/static'
      ]
    bump:
      options:
        part: 'patch'
      files: [ 'package.json', 'bower.json']
    copy:
      root:
        files: [
          cwd: 'src'
          src: [
            '*.html'
          ]
          dest: 'src/static'
          filter: 'isFile'
          expand: true
        ]
      bootstrap:
        files: [
          cwd: 'bower_components/bootstrap/dist'
          src: [
            'css/*.min.css'
            'css/*.map'
            'fonts/*'
            'js/*.min.js'
            'js/*.map'
          ]
          dest: 'src/static'
          expand: true
        ]
      angular:
        files: [
          cwd: 'bower_components/angular/'
          src: [
            'angular.js'
            'angular.min.js'
            'angular.min.js.map'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      storage:
        files: [
          cwd: 'bower_components/angular-local-storage/'
          src: [
            'angular-local-storage.min.js'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      jquery:
        files: [
          cwd: 'bower_components/jquery/dist'
          src: [
            'jquery.min.js'
            'jquery.min.map'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      upload:
        files: [
          cwd: 'bower_components/ng-file-upload'
          src: [
            'angular-file-upload-html5-shim.min.js'
            'angular-file-upload.min.js'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      hotkey:
        files: [
          cwd: 'bower_components/ng-hotkey'
          src: [
            'hotkey.min.js'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      socket:
        files: [
          cwd: 'bower_components/ngSocket/dist'
          src: [
            'ngSocket.js'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      ui:
        files: [
          cwd: 'bower_components/angular-bootstrap'
          src: [
            'ui-bootstrap-tpls.min.js'
          ]
          dest: 'src/static/js'
          expand: true
          filter: 'isFile'
        ]
      #resize:
      #  files: [
      #    cwd: 'bower_components/jquery-resize'
      #    src: [
      #      'jquery.ba-resize.min.js'
      #    ]
      #    dest: 'src/static/js'
      #    expand: true
      #    filter: 'isFile'
      #  ]
      css:
        files: [
          cwd: 'src/css'
          src: [
            'main.css'
          ]
          dest: 'src/static/css'
          expand: true
          filter: 'isFile'
        ]
    coffee:
      options:
        bare: true
      main:
        files:
          'src/static/js/main.min.js': [
            'src/js/main.coffee'
            'src/js/login.coffee'
          ]
    uglify:
      main:
        files:
          'dist/static/js/main.min.js': [
            'src/static/js/main.min.js'
          ]
    cssmin:
      toolbox:
        expand: true
        cwd: 'src/static/css/'
        src: ['*.css', '!*.min.css'],
        dest: 'dist/css/'
        #ext: '.min.css'
    watch:
      css:
        files: [
          'src/css/*.css'
        ]
        tasks: ['copy:css']
      html:
        files: [
          'src/*.html'
        ]
        tasks: ['copy:root']
      coffee:
        files: [
          'src/js/*.coffee'
        ]
        tasks: ['coffee']
    karma:
      options:
        configFile: 'karma.conf.js'
      dev:
        colors: true,
      travis:
        singleRun: true
        autoWatch: false
  )
  grunt.registerTask('test', ['karma'])
  grunt.registerTask('dev', [
    'clean'
    'copy',
    'coffee'
  ])
  grunt.registerTask('dist', [
    'dev'
    'uglify'
  ])
  grunt.registerTask('deploy', [
    'bump'
    'dist'
  ])
  grunt.registerTask('travis', 'travis test', ['karma:travis'])
  grunt.registerTask('default', ['dist'])
