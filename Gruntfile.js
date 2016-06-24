// Generated by CoffeeScript 1.7.1
(function() {
  var myUtils, prompt, _;

  prompt = require('./utils/prompt');

  myUtils = require('./utils/myUtils');

  _ = require('underscore');

  module.exports = function(grunt) {
    var addTask;
    grunt.initConfig({
      init: {
        files: ['package.json', 'restart.sh', 'config/index.json', 'routes/index.coffee', 'routes/index.js']
      },
      add: {
        controllers: {
          src: 'template/controllers/',
          dest: 'controllers/'
        },
        models: {
          src: 'template/models/',
          dest: 'models/'
        },
        permissions: {
          src: 'template/permissions/',
          dest: 'permissions/'
        },
        restful: {
          src: 'template/restful/',
          dest: 'restful/'
        },
        app: {
          src: 'template/app/',
          dest: 'public/app/'
        },
        nav: {
          src: 'template/nav.html',
          dest: 'views/baseApp.ejs',
          replaceText: '<!--{{nav}}-->'
        }
      }
    });
    grunt.registerMultiTask('init', function() {
      var done, filesSrc;
      done = this.async();
      filesSrc = this.filesSrc;
      return prompt({
        'PRJ_NAME': ['project name', 'node_framework'],
        'TITLE': ['web app title', 'node_framework'],
        'PORT': ['web app port', '3000'],
        'DB_HOST': ['mysql host', 'localhost'],
        'DB_PORT': ['mysql server port', '3306'],
        'DB_NAME': ['database name', 'test'],
        'DB_USER': ['database username', 'test'],
        'DB_PASSWD': ['database password', '123456'],
        'ROOT_SECRET': ['root secret of web app', myUtils.genNumPass()],
        'DEFAULT_APP': ['default app of web app', 'user']
      }, function(err, answers) {
        if (err) {
          grunt.log.error(err);
        }
        if (err) {
          return done(false);
        }
        grunt.log.writeln(JSON.stringify(answers));
        _.each(filesSrc, function(file) {
          var content;
          content = grunt.file.read(file);
          if (content) {
            _.each(answers, function(val, key) {
              var replacePattern;
              replacePattern = myUtils.RegExpEscape("{{" + key + "}}");
              return content = content.replace(new RegExp(replacePattern, 'g'), val);
            });
            return grunt.file.write(file, content);
          }
        });
        return done();
      });
    });
    grunt.registerMultiTask('add', function() {
      var done, label, name;
      name = grunt.config('add.name');
      label = grunt.config('add.label');
      if (name && label) {
        return addTask.call(this, name, label);
      } else {
        done = this.async();
        return prompt({
          'name': ['web app name', 'user'],
          'label': ['web app label', '用户管理']
        }, (function(_this) {
          return function(err, answers) {
            if (err) {
              grunt.log.error(err);
            }
            if (err) {
              return done(false);
            }
            grunt.log.writeln(JSON.stringify(answers));
            name = answers.name, label = answers.label;
            grunt.config('add.name', name);
            grunt.config('add.label', label);
            return addTask.call(_this, name, label, done);
          };
        })(this));
      }
    });
    return addTask = function(name, label, done) {
      var replaceText;
      grunt.log.writeln(JSON.stringify(this));
      replaceText = this.data.replaceText;
      if (replaceText) {
        _.each(this.files, function(file) {
          var destContent, replaceContent;
          replaceContent = '';
          _.each(file.src, function(file) {
            return replaceContent += grunt.file.read(file);
          });
          replaceContent = replaceContent.replace(new RegExp(myUtils.RegExpEscape("{{name}}"), 'g'), name);
          replaceContent = replaceContent.replace(new RegExp(myUtils.RegExpEscape("{{label}}"), 'g'), label);
          replaceContent += "\n" + replaceText;
          destContent = grunt.file.read(file.dest);
          destContent = destContent.replace(new RegExp(myUtils.RegExpEscape(replaceText), 'g'), replaceContent);
          return grunt.file.write(file.dest, destContent);
        });
      }
      return typeof done === "function" ? done() : void 0;
    };
  };

}).call(this);