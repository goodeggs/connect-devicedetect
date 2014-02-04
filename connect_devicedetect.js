var checkMobile = require('connect-mobile-detection')();

function updateVary (res) {
  var vary = res.getHeader('vary') || '',
      varyHeaders = vary.split(', ');

  varyHeaders = varyHeaders.filter(function (header) {
    return header.toLowerCase() != 'x-ua-device';
  });
  varyHeaders.push('User-Agent');
  res.setHeader('vary', varyHeaders.join(', '));
}

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

        updateVary(res);
        return next();
      });
    }
  };
};
