express = require 'express'
router = express.Router()

router.get '/', (req, res) ->
  res.render 'baseApp',
    module: '{{name}}'
    title: '{{label}}'

module.exports = router
