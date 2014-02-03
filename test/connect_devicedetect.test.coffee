deviceDetect = require '..'
connect = require 'connect'
assert = require 'assert'
supertest = require 'supertest'

userAgents =
  iPhone: 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_2 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A4449d Safari/9537.53'
  firefox: 'Mozilla/5.0 (Windows NT 6.1; Intel Mac OS X 10.6; rv:7.0.1) Gecko/20100101 Firefox/7.0.1'

describe 'connect-devicedetect', ->
  {request, req} = {}

  beforeEach ->
    app = connect()
      .use deviceDetect()
      .use (request, res, next) ->
        req = request
        next()
      .use (req, res) ->
        res.end 'ok'
    request = supertest app

  it 'sets X-UA-Device request and response headers', (done) ->
    request.get('/').end (err, res) ->
      assert req.headers['x-ua-device']
      assert res.headers['x-ua-device']
      done()

  it 'buckets iPhone user-agent as phone', (done) ->
    request.get('/')
      .set('User-Agent', userAgents.iPhone)
      .expect('X-UA-Device', 'phone')
      .end(done)

  it 'buckets buckets non-phone user-agents as desktop', (done) ->
    request.get('/')
      .set('User-Agent', userAgents.firefox)
      .expect('X-UA-Device', 'desktop')
      .end(done)
