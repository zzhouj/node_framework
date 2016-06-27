_ = require 'underscore'
path = require 'path'
prompt = require './utils/prompt'
myUtils = require './utils/myUtils'

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    init:
      files: [
        'package.json'
        'restart.sh'
        'config/index.json'
        'routes/index.coffee'
        'routes/index.js'
      ]
    add:
      controllers:
        cwd: 'template/controllers/'
        filter: 'isFile'
        src: '**'
        dest: 'controllers/'
      models:
        cwd: 'template/models/'
        filter: 'isFile'
        src: '**'
        dest: 'models/'
      permissions:
        cwd: 'template/permissions/'
        filter: 'isFile'
        src: '**'
        dest: 'permissions/'
      restful:
        cwd: 'template/restful/'
        filter: 'isFile'
        src: '**'
        dest: 'restful/'
      app:
        cwd: 'template/app/'
        filter: 'isFile'
        src: '**'
        dest: 'public/app/'
      nav:
        cwd: 'template/'
        src: 'nav.html'
        dest: 'views/baseApp.ejs'
        replaceText: '<!--{{nav}}-->'
    clean:
      dist: ['dist/']
      coffee_js: ['dist/**/*.coffee.js']
    coffee:
      dist:
        expand: true
        src: ['{controllers,models,permissions,public,restful,routes,utils}/**/*.coffee']
        dest: 'dist/<%= pkg.name %>/'
        ext: '.coffee.js'
    copy:
      dist:
        expand: true
        src: [
          '{bin,config,views,public}/**'
          '!**/*.{coffee,js}'
          'public/javascripts/vendor/**/*.js'
          'app.js'
          'package.json'
          'restart.sh'
        ]
        dest: 'dist/<%= pkg.name %>/'
    uglify:
      dist:
        expand: true
        src: ['dist/<%= pkg.name %>/**/*.coffee.js']
        ext: '.js'
    compress:
      dist:
        options:
          archive: 'dist/<%= pkg.name %>_<%= grunt.template.today("yyyy-mm-dd") %>.tar.gz'
          mode: 'tgz'
        expand: true
        cwd: 'dist/'
        src: '**'
    sql:
      models:
        cwd: 'models/'
        src: ['**.js', '!baseModel.js']
        dest: 'sql/'
    tpl:
      models:
        cwd: 'models/'
        src: ['**.js', '!baseModel.js']
        dest: 'public/app/'

  grunt.registerMultiTask 'init', ->
    done = @async()
    {filesSrc} = @
    prompt
      'PRJ_NAME': ['project name', 'node_framework']
      'TITLE': ['web app title', 'node_framework']
      'PORT': ['web app port', '3000']
      'DB_HOST': ['mysql host', 'localhost']
      'DB_PORT': ['mysql server port', '3306']
      'DB_NAME': ['database name', 'test']
      'DB_USER': ['database username', 'test']
      'DB_PASSWD': ['database password', '123456']
      'RDS_HOST': ['redis host', 'localhost']
      'RDS_PORT': ['redis server port', '6379']
      'ROOT_SECRET': ['root secret of web app', myUtils.genNumPass()]
      'DEFAULT_APP': ['default app of web app', 'user']
    , (err, answers) ->
      grunt.log.error err if err
      return done false if err
      grunt.log.writeln JSON.stringify answers
      _.each filesSrc, (file) ->
        content = grunt.file.read file
        if content
          _.each answers, (val, key) ->
            content = myUtils.replaceAll content, "{{#{key}}}", val
          grunt.file.write file, content
      done()

  grunt.registerMultiTask 'add', ->
    name = grunt.config 'add.name'
    label = grunt.config 'add.label'
    if name and label
      addTask.call @, name, label
    else
      done = @async()
      prompt
        'name': ['web app name', 'user']
        'label': ['web app label', '用户管理']
      , (err, answers) =>
        grunt.log.error err if err
        return done false if err
        grunt.log.writeln JSON.stringify answers
        {name, label} = answers
        grunt.config 'add.name', name
        grunt.config 'add.label', label
        addTask.call @, name, label, done

  addTask = (name, label, done) ->
    {replaceText} = @data
    if replaceText
      _.each @files, (file) ->
        withText = ''
        _.each file.src, (srcFile) ->
          withText += grunt.file.read path.join file.cwd, srcFile
        withText = myUtils.replaceAll withText, "{{name}}", name
        withText = myUtils.replaceAll withText, "{{label}}", label
        withText += "\n            " + replaceText
        grunt.file.write file.dest, myUtils.replaceAll grunt.file.read(file.dest), replaceText, withText
    else
      _.each @files, (file) ->
        _.each file.src, (srcFile) ->
          destFile = srcFile.replace new RegExp(myUtils.RegExpEscape("{{name}}"), 'g'), name
          destFile = path.join file.dest, destFile
          srcFile = path.join file.cwd, srcFile
          grunt.file.copy srcFile, destFile,
            process: (content) ->
              content = myUtils.replaceAll content, "{{name}}", name
              content = myUtils.replaceAll content, "{{label}}", label
    done?()

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'

  grunt.registerTask 'dist', [
    'clean:dist'
    'copy:dist'
    'coffee:dist'
    'uglify:dist'
    'clean:coffee_js'
    'compress:dist'
  ]

  grunt.registerMultiTask 'sql', ->
    _.each @files, (file) ->
      _.each file.src, (srcFile) ->
        destFile = path.join file.dest, srcFile.replace /\.js$/, '.sql'
        srcFile = path.join file.cwd, srcFile
        try
          model = require "./#{srcFile}"
        catch e
        sql = model?.createTableSql?()
        if sql
          grunt.log.writeln "writing >> #{destFile}"
          grunt.file.write destFile, sql

  grunt.registerMultiTask 'tpl', ->
    done = @async()
    _.each @files, (file) ->
      candidates = _.map file.src, (srcFile) ->
        srcFile: path.join file.cwd, srcFile
        model: srcFile.match(/(.+)\.js/)[1]
      hint = _.map(candidates, (candidate, i) ->
        "#{i}: #{candidate.model}"
      ).join '\n'
      prompt
        'candidateIndex': ["candidate index\n#{hint}\n", 'no default']
      , (err, answers) ->
        grunt.log.error err if err
        return done false if err
        candidate = candidates[answers.candidateIndex]
        grunt.log.error 'invalid candidate index' unless candidate
        return done false unless candidate
        candidate.destFiles = [
          path.join file.dest, candidate.model, 'tpl/edit.tpl.html'
          path.join file.dest, candidate.model, 'tpl/list.tpl.html'
        ]
        tplTask candidate
        done()

  tplTask = (candidate) ->
    try
      model = require "./#{srcFile}"
    catch e
