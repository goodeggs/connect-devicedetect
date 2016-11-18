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
        var detailedDevice;
        var isIOS = /iPad|iPhone|iPod/.test(req.headers['user-agent'])
        var isAndroid = /Android.+Chrome\/[.0-9]*/.test(req.headers['user-agent'])
        if (req.phone) {
          device = 'phone';
          if (isIOS) {
            detailedDevice = 'mobile-iphone';
          }
          else if (isAndroid) {
            detailedDevice = 'mobile-android';
          }
        } else if (req.tablet) {
          device = 'tablet';
          if (isIOS) {
            detailedDevice = 'tablet-ipad';
          }
          else if (isAndroid) {
            detailedDevice = 'tablet-android';
          }
        } else {
          device = 'desktop';
        }

        isIOS = /iPad|iPhone|iPod/.test(req.headers['user-agent'])

        req.headers['x-ua-device'] = device;
        res.setHeader('X-UA-Device', device);
        if (detailedDevice) {
          req.headers['x-ua-device-detailed'] = detailedDevice;
          res.setHeader('X-UA-Device-Detailed', detailedDevice);
        }
        updateVary(res);

        return next();
      });
    }
  };
};
