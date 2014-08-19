deviceDetect = require '..'
connect = require 'connect'
assert = require 'assert'
request = require 'supertest'

userAgents =
  iPhone: 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_2 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A4449d Safari/9537.53'
  iPad: 'Mozilla/5.0 (iPad; CPU OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B329 Safari/8536.25'
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
        .end(done)

    it 'buckets iPad user-agent as desktop by default', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.iPad)
        .expect('X-UA-Device', 'desktop')
        .end(done)

    it 'buckets buckets non-phone user-agents as desktop', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.firefox)
        .expect('X-UA-Device', 'desktop')
        .end(done)


  describe 'options', ->
    {app} = {}

    beforeEach ->
      app = connect()
        .use(deviceDetect({allMobileAsPhone: true}))
        .use(send)

    it 'can bucket tablets as phone', (done) ->
      request(app).get('/')
        .set('User-Agent', userAgents.iPad)
        .expect('X-UA-Device', 'phone')
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
