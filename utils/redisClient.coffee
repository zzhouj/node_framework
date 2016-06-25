redis = require 'redis'
config = require '../config'

client = redis.createClient config.redis.port, config.redis.host

module.exports = client