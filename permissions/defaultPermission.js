// Generated by CoffeeScript 1.7.1
(function() {
  module.exports = function(req, res, next) {
    var state;
    if (req.path.match('^/(login|logout|javascripts|stylesheets|views)')) {
      return next();
    } else if (req.session.user) {
      req.session.user.t = Date.now();
      res.locals.user = req.session.user;
      return next();
    } else {
      state = encodeURIComponent(req.url);
      return res.redirect("/login?state=" + state);
    }
  };

}).call(this);
