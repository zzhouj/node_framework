mysql = require 'mysql'
config = require '../config'

mysqlPool = mysql.createPool config.mysql

module.exports = mysqlPool
