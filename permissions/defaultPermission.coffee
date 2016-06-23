module.exports = (req, res, next) ->
  if req.path.match('^/(login|logout|javascripts|stylesheets|views)')
    next()
  else if req.session.user
    req.session.user.t = Date.now()
    res.locals.user = req.session.user
    next()
  else
    res.redirect '/login'
