connect-devicedetect [![NPM version](https://badge.fury.io/js/connect-devicedetect.png)](http://badge.fury.io/js/connect-devicedetect) [![Build Status](https://travis-ci.org/goodeggs/connect-devicedetect.png)](https://travis-ci.org/goodeggs/connect-devicedetect)
==============

Connect middleware to bucket user-agent strings into device groups.  Sets X-UA-Device header to device buckets like `phone` or `desktop` based on user-agent.  Useful as a development-time stub for edge-cache based detection like [varnish-devicedetect](https://github.com/varnish/varnish-devicedetect/). when Fastly isn't already

```js
connect = require 'connect'
deviceDetect = require 'connect-devicedetect'

app = connect().use(deviceDetect())
```
