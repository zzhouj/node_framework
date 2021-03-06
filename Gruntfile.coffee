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
    remove:
      controllers:
        src: [
          'controllers/{{name}}Controller.coffee'
          'controllers/{{name}}Controller.js'
        ]
      models:
        src: [
          'models/{{name}}.coffee'
          'models/{{name}}.js'
        ]
      permissions:
        src: [
          'permissions/{{name}}Permission.coffee'
          'permissions/{{name}}Permission.js'
        ]
      restful:
        src: [
          'restful/{{name}}Restful.coffee'
          'restful/{{name}}Restful.js'
        ]
      app:
        src: [
          'public/app/{{name}}/'
        ]
      sql:
        src: [
          'sql/{{name}}.sql'
        ]
    clean:
      dist: ['dist/']
      coffee_js: ['dist/**/*.coffee.js']
    coffee:
      dist:
        expand: true
        src: ['{controllers,crons,models,permissions,public,restful,routes,utils}/**/*.coffee']
        dest: 'dist/<%= pkg.name %>/'
        ext: '.coffee.js'
    copy:
      dist:
        expand: true
        src: [
          '{bin,config,views,public}/**'
          '!**/*.{coffee,js}'
          '!public/download/**'
          'public/javascripts/vendor/**/*.js'
          'app.js'
          'Gruntfile.js'
          'package.json'
          'restart.sh'
        ]
        dest: 'dist/<%= pkg.name %>/'
    uglify:
      dist:
        expand: true
        src: ['dist/<%= pkg.name %>/**/*.coffee.js']
        ext: '.js'
    fixconfig:
      dist:
        options:
          mysqlHost: '10.6.22.97'
          redisHost: '10.6.25.201'
        src: 'dist/<%= pkg.name %>/config/index.json'
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
      grunt.log.writeln JSON.stringify answers, null, 4
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
        grunt.log.writeln JSON.stringify answers, null, 4
        {name, label} = answers
        grunt.config 'add.name', name
        grunt.config 'add.label', label
        addTask.call @, name, label, done

  grunt.registerMultiTask 'remove', ->
    name = grunt.config 'remove.name'
    label = grunt.config 'remove.label'
    if name and label
      removeTask.call @, name, label
    else
      done = @async()
      prompt
        'name': ['web app name', 'user']
        'label': ['web app label', '用户管理']
      , (err, answers) =>
        grunt.log.error err if err
        return done false if err
        grunt.log.writeln JSON.stringify answers, null, 4
        {name, label} = answers
        grunt.config 'remove.name', name
        grunt.config 'remove.label', label
        removeTask.call @, name, label, done

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

  removeTask = (name, label, done) ->
    for src in @data.src
      grunt.file.delete src.replace new RegExp(myUtils.RegExpEscape("{{name}}"), 'g'), name
    done?()

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.registerTask 'dist', [
    'clean:dist'
    'copy:dist'
    'coffee:dist'
    'uglify:dist'
    'clean:coffee_js'
    'fixconfig:dist'
    'compress:dist'
  ]

  grunt.registerMultiTask 'fixconfig', ->
    return grunt.log.error 'no options' unless @data.options
    {port, mysqlHost, mysqlPort, mysqlUser, mysqlPassword, redisHost, rootSecret, cdnUrl} = @data.options
    for src in @filesSrc
      config = grunt.file.readJSON src
      if config
        config.port = port if port
        config.mysql.host = mysqlHost if mysqlHost
        config.mysql.port = mysqlPort if mysqlPort
        config.mysql.user = mysqlUser if mysqlUser
        config.mysql.password = mysqlPassword if mysqlPassword
        config.redis.host = redisHost if redisHost
        config.rootSecret = rootSecret if rootSecret
        config.cdnUrl = cdnUrl if cdnUrl
        grunt.file.write src, JSON.stringify config, null, 4

  grunt.registerMultiTask 'sql', ->
    _.each @files, (file) ->
      _.each file.src, (srcFile) ->
        destFile = path.join file.dest, srcFile.replace /\.js$/, '.sql'
        srcFile = path.join file.cwd, srcFile
        try
          model = require "./#{srcFile}"
        catch e
          console.log e
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
        candidate.destFiles = _.filter [
          path.join file.dest, candidate.model, 'tpl/edit.tpl.html'
          path.join file.dest, candidate.model, 'tpl/list.tpl.html'
        ], (destFile) ->
          grunt.file.exists(destFile)
        tplTask candidate
        done()

  tplTask = (candidate) ->
    model = require "./#{candidate.srcFile}"
    labels = model.table?.labels || {}
    {schema} = model.table
    options = _.mapObject labels, (label, field) ->
      option = schema?[field]
      option = if option?.type? then option else {type: option}
      option.isNotNull = true unless option.isNotNull?
      option
    replaceMap = {}
    replaceMap['{{name.label}}'] = labels.name if labels.name
    replaceMap['{{model.label}}'] = labels.$model if labels.$model
    destContents = _.map candidate.destFiles, (destFile) ->
      grunt.file.read(destFile)
    labels = _.omit labels, (label, field) ->
      return true if field == '$model'
      for destContent in destContents
        return true if destContent?.match new RegExp "item\\.#{myUtils.RegExpEscape field}"
      false
    indent = '                '
    replaceMap["<!--{{field.label}}-->"] = _.map(_.values(labels), (label) ->
        "<td>#{label}</td>"
      ).join("\n#{indent}") + "\n#{indent}<!--{{field.label}}-->"
    replaceMap["<!--{{field.value}}-->"] = _.map(_.keys(labels), (field) ->
        if options[field]?.type == Number
          "<td>{{item.#{field} | number}}</td>"
        else if options[field]?.type == Date
          "<td>{{item.#{field} | date:'MM-dd HH:mm'}}</td>"
        else
          "<td>{{item.#{field}}}</td>"
      ).join("\n#{indent}") + "\n#{indent}<!--{{field.value}}-->"
    labels = _.omit labels, 'createTime', 'updateTime'
    indent = '        '
    replaceMap["#{indent}<!--{{field.input}}-->"] = _.map(labels, (label, field) ->
        typeAttr = ''
        if options[field]?.type == Number
          typeAttr = ' type="number"'
        else if options[field]?.type == Date
          typeAttr = ' type="datetime-local"'
        requireAttr = if options[field]?.isNotNull then ' required' else ''
        """
      #{indent}<div class="form-group">
      #{indent}    <label for="#{field}">#{label}：</label>
      #{indent}    <input class="form-control" id="#{field}" ng-model="item.#{field}"#{typeAttr}#{requireAttr}>
      #{indent}</div>
      """
      ).join('\n') + "\n#{indent}<!--{{field.input}}-->"
    _.each candidate.destFiles, (destFile) ->
      _.each replaceMap, (withText, replaceText) ->
        grunt.file.write destFile, myUtils.replaceAll grunt.file.read(destFile), replaceText, withText
