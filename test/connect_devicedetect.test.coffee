deviceDetect = require '..'
connect = require 'connect'
assert = require 'assert'
request = require 'supertest'

userAgents =
  iPhone: 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_2 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A4449d Safari/9537.53'
  iPad: 'Mozilla/5.0 (iPad; CPU OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B329 Safari/8536.25'
  androidPhone: 'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19'
  androidTable: 'Mozilla/5.0 (Linux; Android 5.0.2; SAMSUNG SM-T550 Build/LRX22G) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/3.3 Chrome/38.0.2125.102 Safari/537.36'
  firefox: 'Mozilla/5.0 (Windows NT 6.1; Intel Mac OS X 10.6; rv:7.0.1) Gecko/20100101 Firefox/7.0.1'

send = (req, res) ->
  res.end 'ok'

vary = (headers) ->
  (req, res, next) ->
    res.setHeader 'Vary', [headers, res.getHeader('Vary')].filter(Boolean).join(', ')
    next()

describe 'connect-devicedetect', ->

  describe 'bucketing', ->
    {app} = {}

    beforeEach ->
      app = connect()
        .use(deviceDetect())
        .use(send)

    it 'buckets iPhone user-agent as phone', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.iPhone)
        .expect('X-UA-Device', 'phone')
        .expect('X-UA-Device-Detailed', 'mobile-iphone')
        .end(done)

    it 'buckets iPad user-agent as tablet', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.iPad)
        .expect('X-UA-Device', 'tablet')
        .expect('X-UA-Device-Detailed', 'tablet-ipad')
        .end(done)


    it 'buckets android phone user-agent as phone', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.androidPhone)
        .expect('X-UA-Device', 'phone')
        .expect('X-UA-Device-Detailed', 'mobile-android')
        .end(done)

    it 'buckets android tablet user-agent as tablet', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.androidTable)
        .expect('X-UA-Device', 'tablet')
        .expect('X-UA-Device-Detailed', 'tablet-android')
        .end(done)

    it 'buckets buckets non-phone user-agents as desktop', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.firefox)
        .expect('X-UA-Device', 'desktop')
        .end(done)


  describe 'headers', ->
    it 'sets X-UA-Device request and response headers', (done) ->
      app = connect()
        .use deviceDetect()
        .use (req, res, next) ->
          assert res.getHeader 'x-ua-device'
          assert req.headers['x-ua-device']
          next()
        .use(send)

      request(app).get('/')
        .expect('X-UA-Device', 'desktop')
        .expect(200, done)

    it 'adds Vary: User-Agent for downstream caches only', (done) ->
      app = connect()
        .use(vary 'Accept-Encoding')
        .use(deviceDetect())
        .use (req, res, next) ->
          assert !/User-Agent/.test res.getHeader('Vary')
          next()
        .use(send)

      request(app).get('/')
        .expect('Vary', 'Accept-Encoding, User-Agent')
        .expect(200, done)

    describe 'when Vary: X-UA-Device is added upstream', ->
      {app} = {}
      beforeEach ->
        app = connect()
          .use(deviceDetect())
          .use(vary 'X-UA-Device, Accept-Encoding')
          .use(send)

      it 'strips Vary: X-UA-Device for downstream caches only', (done) ->
        request(app).get('/')
          .expect('Vary', 'Accept-Encoding, User-Agent')
          .end(done)
