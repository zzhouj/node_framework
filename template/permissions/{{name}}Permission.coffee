module.exports = (req, res, next) ->
  if req.session.user?.admin
    next()
  else
    res.send 403, 'Sorry, access denied!'
