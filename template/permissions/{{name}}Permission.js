// Generated by CoffeeScript 1.7.1
(function() {
  module.exports = function(req, res, next) {
    var _ref;
    if ((_ref = req.session.user) != null ? _ref.admin : void 0) {
      return next();
    } else {
      return res.send(403, 'Sorry, access denied!');
    }
  };

}).call(this);
