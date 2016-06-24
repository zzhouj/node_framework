prompt = require './utils/prompt'
myUtils = require './utils/myUtils'
_ = require 'underscore'

module.exports = (grunt) ->
  grunt.initConfig
    init:
      files: [
        'package.json'
        'restart.sh'
        'config/index.json'
        'routes/index.coffee'
        'routes/index.js'
      ]
    add:
      controllers: {src: 'template/controllers/', dest: 'controllers/'}
      models: {src: 'template/models/', dest: 'models/'}
      permissions: {src: 'template/permissions/', dest: 'permissions/'}
      restful: {src: 'template/restful/', dest: 'restful/'}
      app: {src: 'template/app/', dest: 'public/app/'}
      nav: {src: 'template/nav.html', dest: 'views/baseApp.ejs', replaceText: '<!--{{nav}}-->'}

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
            replacePattern = myUtils.RegExpEscape "{{#{key}}}"
            content = content.replace new RegExp(replacePattern, 'g'), val
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
    grunt.log.writeln JSON.stringify @
    {replaceText} = @data
    if replaceText
      _.each @files, (file) ->
        replaceContent = ''
        _.each file.src, (file) ->
          replaceContent += grunt.file.read file
        replaceContent = replaceContent.replace new RegExp(myUtils.RegExpEscape("{{name}}"), 'g'), name
        replaceContent = replaceContent.replace new RegExp(myUtils.RegExpEscape("{{label}}"), 'g'), label
        replaceContent += "\n" + replaceText
        destContent = grunt.file.read file.dest
        destContent = destContent.replace new RegExp(myUtils.RegExpEscape(replaceText), 'g'), replaceContent
        grunt.file.write file.dest, destContent
    done?()
