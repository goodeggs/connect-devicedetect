var checkMobile = require('connect-mobile-detection')();

module.exports = function () {
  return function(req, res, next) {
    if (req.headers['x-ua-device']) {
      return next();
    } else {
      checkMobile(req, res, function() {
        var device;
        if (req.phone) {
          device = 'phone';
        } else {
          device = 'desktop';
        }
        req.headers['x-ua-device'] = device;
        res.setHeader('X-UA-Device', device);
        return next();
      });
    }
  }
};
