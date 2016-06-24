readline = require 'readline'
async = require 'async'
_ = require 'underscore'

module.exports = (questions, cb) ->
  return cb 'no questions' unless questions
  rl = readline.createInterface {input: process.stdin, output: process.stdout}
  tasks = []
  _.each questions, (q, key) ->
    tasks.push (cb) ->
      rl.question "please input #{q[0]} (#{q[1] || ''}):", (answer) ->
        answer = answer || q[1]
        return cb 'no answer' unless answer
        cb null, {key, answer}
  return cb 'no questions' unless tasks.length > 0
  async.series tasks, (err, results) ->
    rl.close()
    return cb err if err
    answers = {}
    for r in results
      answers[r.key] = r.answer
    cb null, answers