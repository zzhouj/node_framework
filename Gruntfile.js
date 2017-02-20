// Generated by CoffeeScript 1.7.1
(function() {
  var myUtils, path, prompt, _;

  _ = require('underscore');

  path = require('path');

  prompt = require('./utils/prompt');

  myUtils = require('./utils/myUtils');

  module.exports = function(grunt) {
    var addTask, removeTask, tplTask;
    grunt.initConfig({
      pkg: grunt.file.readJSON('package.json'),
      init: {
        files: ['package.json', 'restart.sh', 'config/index.json', 'routes/index.coffee', 'routes/index.js']
      },
      add: {
        controllers: {
          cwd: 'template/controllers/',
          filter: 'isFile',
          src: '**',
          dest: 'controllers/'
        },
        models: {
          cwd: 'template/models/',
          filter: 'isFile',
          src: '**',
          dest: 'models/'
        },
        permissions: {
          cwd: 'template/permissions/',
          filter: 'isFile',
          src: '**',
          dest: 'permissions/'
        },
        restful: {
          cwd: 'template/restful/',
          filter: 'isFile',
          src: '**',
          dest: 'restful/'
        },
        app: {
          cwd: 'template/app/',
          filter: 'isFile',
          src: '**',
          dest: 'public/app/'
        },
        nav: {
          cwd: 'template/',
          src: 'nav.html',
          dest: 'views/baseApp.ejs',
          replaceText: '<!--{{nav}}-->'
        }
      },
      remove: {
        controllers: {
          src: ['controllers/{{name}}Controller.coffee', 'controllers/{{name}}Controller.js']
        },
        models: {
          src: ['models/{{name}}.coffee', 'models/{{name}}.js']
        },
        permissions: {
          src: ['permissions/{{name}}Permission.coffee', 'permissions/{{name}}Permission.js']
        },
        restful: {
          src: ['restful/{{name}}Restful.coffee', 'restful/{{name}}Restful.js']
        },
        app: {
          src: ['public/app/{{name}}/']
        },
        sql: {
          src: ['sql/{{name}}.sql']
        }
      },
      clean: {
        dist: ['dist/'],
        coffee_js: ['dist/**/*.coffee.js']
      },
      coffee: {
        dist: {
          expand: true,
          src: ['{controllers,crons,models,permissions,public,restful,routes,utils}/**/*.coffee'],
          dest: 'dist/<%= pkg.name %>/',
          ext: '.coffee.js'
        }
      },
      copy: {
        dist: {
          expand: true,
          src: ['{bin,config,views,public}/**', '!**/*.{coffee,js}', '!public/download/**', 'public/javascripts/vendor/**/*.js', 'app.js', 'Gruntfile.js', 'package.json', 'restart.sh'],
          dest: 'dist/<%= pkg.name %>/'
        }
      },
      uglify: {
        dist: {
          expand: true,
          src: ['dist/<%= pkg.name %>/**/*.coffee.js'],
          ext: '.js'
        }
      },
      fixconfig: {
        dist: {
          options: {
            mysqlHost: '10.6.22.97',
            redisHost: '10.6.25.201'
          },
          src: 'dist/<%= pkg.name %>/config/index.json'
        }
      },
      compress: {
        dist: {
          options: {
            archive: 'dist/<%= pkg.name %>_<%= grunt.template.today("yyyy-mm-dd") %>.tar.gz',
            mode: 'tgz'
          },
          expand: true,
          cwd: 'dist/',
          src: '**'
        }
      },
      sql: {
        models: {
          cwd: 'models/',
          src: ['**.js', '!baseModel.js'],
          dest: 'sql/'
        }
      },
      tpl: {
        models: {
          cwd: 'models/',
          src: ['**.js', '!baseModel.js'],
          dest: 'public/app/'
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
        'RDS_HOST': ['redis host', 'localhost'],
        'RDS_PORT': ['redis server port', '6379'],
        'ROOT_SECRET': ['root secret of web app', myUtils.genNumPass()],
        'DEFAULT_APP': ['default app of web app', 'user']
      }, function(err, answers) {
        if (err) {
          grunt.log.error(err);
        }
        if (err) {
          return done(false);
        }
        grunt.log.writeln(JSON.stringify(answers, null, 4));
        _.each(filesSrc, function(file) {
          var content;
          content = grunt.file.read(file);
          if (content) {
            _.each(answers, function(val, key) {
              return content = myUtils.replaceAll(content, "{{" + key + "}}", val);
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
            grunt.log.writeln(JSON.stringify(answers, null, 4));
            name = answers.name, label = answers.label;
            grunt.config('add.name', name);
            grunt.config('add.label', label);
            return addTask.call(_this, name, label, done);
          };
        })(this));
      }
    });
    grunt.registerMultiTask('remove', function() {
      var done, label, name;
      name = grunt.config('remove.name');
      label = grunt.config('remove.label');
      if (name && label) {
        return removeTask.call(this, name, label);
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
            grunt.log.writeln(JSON.stringify(answers, null, 4));
            name = answers.name, label = answers.label;
            grunt.config('remove.name', name);
            grunt.config('remove.label', label);
            return removeTask.call(_this, name, label, done);
          };
        })(this));
      }
    });
    addTask = function(name, label, done) {
      var replaceText;
      replaceText = this.data.replaceText;
      if (replaceText) {
        _.each(this.files, function(file) {
          var withText;
          withText = '';
          _.each(file.src, function(srcFile) {
            return withText += grunt.file.read(path.join(file.cwd, srcFile));
          });
          withText = myUtils.replaceAll(withText, "{{name}}", name);
          withText = myUtils.replaceAll(withText, "{{label}}", label);
          withText += "\n            " + replaceText;
          return grunt.file.write(file.dest, myUtils.replaceAll(grunt.file.read(file.dest), replaceText, withText));
        });
      } else {
        _.each(this.files, function(file) {
          return _.each(file.src, function(srcFile) {
            var destFile;
            destFile = srcFile.replace(new RegExp(myUtils.RegExpEscape("{{name}}"), 'g'), name);
            destFile = path.join(file.dest, destFile);
            srcFile = path.join(file.cwd, srcFile);
            return grunt.file.copy(srcFile, destFile, {
              process: function(content) {
                content = myUtils.replaceAll(content, "{{name}}", name);
                return content = myUtils.replaceAll(content, "{{label}}", label);
              }
            });
          });
        });
      }
      return typeof done === "function" ? done() : void 0;
    };
    removeTask = function(name, label, done) {
      var src, _i, _len, _ref;
      _ref = this.data.src;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        src = _ref[_i];
        grunt.file["delete"](src.replace(new RegExp(myUtils.RegExpEscape("{{name}}"), 'g'), name));
      }
      return typeof done === "function" ? done() : void 0;
    };
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-compress');
    grunt.loadNpmTasks('grunt-text-replace');
    grunt.registerTask('dist', ['clean:dist', 'copy:dist', 'coffee:dist', 'uglify:dist', 'clean:coffee_js', 'fixconfig:dist', 'compress:dist']);
    grunt.registerMultiTask('fixconfig', function() {
      var cdnUrl, config, mysqlHost, mysqlPassword, mysqlPort, mysqlUser, port, redisHost, rootSecret, src, _i, _len, _ref, _ref1, _results;
      if (!this.data.options) {
        return grunt.log.error('no options');
      }
      _ref = this.data.options, port = _ref.port, mysqlHost = _ref.mysqlHost, mysqlPort = _ref.mysqlPort, mysqlUser = _ref.mysqlUser, mysqlPassword = _ref.mysqlPassword, redisHost = _ref.redisHost, rootSecret = _ref.rootSecret, cdnUrl = _ref.cdnUrl;
      _ref1 = this.filesSrc;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        src = _ref1[_i];
        config = grunt.file.readJSON(src);
        if (config) {
          if (port) {
            config.port = port;
          }
          if (mysqlHost) {
            config.mysql.host = mysqlHost;
          }
          if (mysqlPort) {
            config.mysql.port = mysqlPort;
          }
          if (mysqlUser) {
            config.mysql.user = mysqlUser;
          }
          if (mysqlPassword) {
            config.mysql.password = mysqlPassword;
          }
          if (redisHost) {
            config.redis.host = redisHost;
          }
          if (rootSecret) {
            config.rootSecret = rootSecret;
          }
          if (cdnUrl) {
            config.cdnUrl = cdnUrl;
          }
          _results.push(grunt.file.write(src, JSON.stringify(config, null, 4)));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    grunt.registerMultiTask('sql', function() {
      return _.each(this.files, function(file) {
        return _.each(file.src, function(srcFile) {
          var destFile, e, model, sql;
          destFile = path.join(file.dest, srcFile.replace(/\.js$/, '.sql'));
          srcFile = path.join(file.cwd, srcFile);
          try {
            model = require("./" + srcFile);
          } catch (_error) {
            e = _error;
            console.log(e);
          }
          sql = model != null ? typeof model.createTableSql === "function" ? model.createTableSql() : void 0 : void 0;
          if (sql) {
            grunt.log.writeln("writing >> " + destFile);
            return grunt.file.write(destFile, sql);
          }
        });
      });
    });
    grunt.registerMultiTask('tpl', function() {
      var done;
      done = this.async();
      return _.each(this.files, function(file) {
        var candidates, hint;
        candidates = _.map(file.src, function(srcFile) {
          return {
            srcFile: path.join(file.cwd, srcFile),
            model: srcFile.match(/(.+)\.js/)[1]
          };
        });
        hint = _.map(candidates, function(candidate, i) {
          return "" + i + ": " + candidate.model;
        }).join('\n');
        return prompt({
          'candidateIndex': ["candidate index\n" + hint + "\n", 'no default']
        }, function(err, answers) {
          var candidate;
          if (err) {
            grunt.log.error(err);
          }
          if (err) {
            return done(false);
          }
          candidate = candidates[answers.candidateIndex];
          if (!candidate) {
            grunt.log.error('invalid candidate index');
          }
          if (!candidate) {
            return done(false);
          }
          candidate.destFiles = [path.join(file.dest, candidate.model, 'tpl/edit.tpl.html'), path.join(file.dest, candidate.model, 'tpl/list.tpl.html')];
          tplTask(candidate);
          return done();
        });
      });
    });
    return tplTask = function(candidate) {
      var destContents, indent, labels, model, options, replaceMap, schema, _ref;
      model = require("./" + candidate.srcFile);
      labels = ((_ref = model.table) != null ? _ref.labels : void 0) || {};
      schema = model.table.schema;
      options = _.mapObject(labels, function(label, field) {
        var option;
        option = schema != null ? schema[field] : void 0;
        option = (option != null ? option.type : void 0) != null ? option : {
          type: option
        };
        if (option.isNotNull == null) {
          option.isNotNull = true;
        }
        return option;
      });
      replaceMap = {};
      if (labels.name) {
        replaceMap['{{name.label}}'] = labels.name;
      }
      if (labels.$model) {
        replaceMap['{{model.label}}'] = labels.$model;
      }
      destContents = _.map(candidate.destFiles, function(destFile) {
        return grunt.file.read(destFile);
      });
      labels = _.omit(labels, function(label, field) {
        var destContent, _i, _len;
        if (field === '$model') {
          return true;
        }
        for (_i = 0, _len = destContents.length; _i < _len; _i++) {
          destContent = destContents[_i];
          if (destContent != null ? destContent.match(new RegExp("item\\." + (myUtils.RegExpEscape(field)))) : void 0) {
            return true;
          }
        }
        return false;
      });
      indent = '                ';
      replaceMap["<!--{{field.label}}-->"] = _.map(_.values(labels), function(label) {
        return "<td>" + label + "</td>";
      }).join("\n" + indent) + ("\n" + indent + "<!--{{field.label}}-->");
      replaceMap["<!--{{field.value}}-->"] = _.map(_.keys(labels), function(field) {
        var _ref1, _ref2;
        if (((_ref1 = options[field]) != null ? _ref1.type : void 0) === Number) {
          return "<td>{{item." + field + " | number}}</td>";
        } else if (((_ref2 = options[field]) != null ? _ref2.type : void 0) === Date) {
          return "<td>{{item." + field + " | date:'MM-dd HH:mm'}}</td>";
        } else {
          return "<td>{{item." + field + "}}</td>";
        }
      }).join("\n" + indent) + ("\n" + indent + "<!--{{field.value}}-->");
      labels = _.omit(labels, 'createTime', 'updateTime');
      indent = '        ';
      replaceMap["" + indent + "<!--{{field.input}}-->"] = _.map(labels, function(label, field) {
        var requireAttr, typeAttr, _ref1, _ref2, _ref3;
        typeAttr = '';
        if (((_ref1 = options[field]) != null ? _ref1.type : void 0) === Number) {
          typeAttr = ' type="number"';
        } else if (((_ref2 = options[field]) != null ? _ref2.type : void 0) === Date) {
          typeAttr = ' type="datetime-local"';
        }
        requireAttr = ((_ref3 = options[field]) != null ? _ref3.isNotNull : void 0) ? ' required' : '';
        return "" + indent + "<div class=\"form-group\">\n" + indent + "    <label for=\"" + field + "\">" + label + "：</label>\n" + indent + "    <input class=\"form-control\" id=\"" + field + "\" ng-model=\"item." + field + "\"" + typeAttr + requireAttr + ">\n" + indent + "</div>";
      }).join('\n') + ("\n" + indent + "<!--{{field.input}}-->");
      return _.each(candidate.destFiles, function(destFile) {
        return _.each(replaceMap, function(withText, replaceText) {
          return grunt.file.write(destFile, myUtils.replaceAll(grunt.file.read(destFile), replaceText, withText));
        });
      });
    };
  };

}).call(this);
