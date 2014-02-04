var checkMobile = require('connect-mobile-detection')();

function updateVary (res) {
  var origWriteHead = res.writeHead;
  // wait until writeHead to modify headers so changes only affect downstream
  res.writeHead = function () {
    var vary = this.getHeader('vary') || '';
    res.setHeader('vary', vary
      .split(', ')
      .filter(Boolean)
      .filter(function (header) {
       return header.toLowerCase() != 'x-ua-device';
      })
      .concat('User-Agent')
      .join(', ')
    );
    origWriteHead.apply(this, arguments);
  };
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
