require('../helper.coffee')
sub = require('code.coffee')

describe 'test', ->

  it 'passes', ->
    return

  it 'tests sub', ->
    sub(2,1).should.equal(1)

  it 'another test', ->
    sub(4,5).should.equal(-1)