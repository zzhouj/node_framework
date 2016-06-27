// Generated by CoffeeScript 1.7.1
(function() {
  var myUtils, path, prompt, _;

  _ = require('underscore');

  path = require('path');

  prompt = require('./utils/prompt');

  myUtils = require('./utils/myUtils');

  module.exports = function(grunt) {
    var addTask, tplTask;
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
      clean: {
        dist: ['dist/'],
        coffee_js: ['dist/**/*.coffee.js']
      },
      coffee: {
        dist: {
          expand: true,
          src: ['{controllers,models,permissions,public,restful,routes,utils}/**/*.coffee'],
          dest: 'dist/<%= pkg.name %>/',
          ext: '.coffee.js'
        }
      },
      copy: {
        dist: {
          expand: true,
          src: ['{bin,config,views,public}/**', '!**/*.{coffee,js}', 'public/javascripts/vendor/**/*.js', 'app.js', 'package.json', 'restart.sh'],
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
        grunt.log.writeln(JSON.stringify(answers));
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
            grunt.log.writeln(JSON.stringify(answers));
            name = answers.name, label = answers.label;
            grunt.config('add.name', name);
            grunt.config('add.label', label);
            return addTask.call(_this, name, label, done);
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
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-compress');
    grunt.registerTask('dist', ['clean:dist', 'copy:dist', 'coffee:dist', 'uglify:dist', 'clean:coffee_js', 'compress:dist']);
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
      var indent, labels, model, options, replaceMap, schema, _ref;
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
      labels = _.omit(labels, '$model');
      indent = '                ';
      replaceMap['<td>{{field.label}}</td>'] = _.map(_.values(labels), function(label) {
        return "<td>" + label + "</td>";
      }).join("\n" + indent);
      replaceMap['<td>{{field.value}}</td>'] = _.map(_.keys(labels), function(field) {
        var _ref1;
        return "<td>{{item." + field + (((_ref1 = options[field]) != null ? _ref1.type : void 0) === Number ? ' | number' : '') + "}}</td>";
      }).join("\n" + indent);
      indent = '        ';
      replaceMap["" + indent + "<div class=\"form-group\">{{field.input}}</div>"] = _.map(labels, function(label, field) {
        var requireAttr, typeAttr, _ref1, _ref2;
        typeAttr = ((_ref1 = options[field]) != null ? _ref1.type : void 0) === Number ? ' type="number"' : '';
        requireAttr = ((_ref2 = options[field]) != null ? _ref2.isNotNull : void 0) ? ' required' : '';
        return "" + indent + "<div class=\"form-group\">\n" + indent + "    <label for=\"" + field + "\">" + label + "：</label>\n" + indent + "    <input class=\"form-control\" id=\"" + field + "\" ng-model=\"item." + field + "\"" + typeAttr + requireAttr + ">\n" + indent + "</div>";
      }).join('\n');
      return _.each(candidate.destFiles, function(destFile) {
        return _.each(replaceMap, function(withText, replaceText) {
          return grunt.file.write(destFile, myUtils.replaceAll(grunt.file.read(destFile), replaceText, withText));
        });
      });
    };
  };

}).call(this);
