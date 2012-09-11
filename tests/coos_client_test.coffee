#
# 11/09/2012
# @mariohct
#
# Unit tests for CooSClientJS tests
#

should = require 'should'
sync = require 'async'

#
# Tests CooSClientJS
#
coosmw = require '../lib/coos_client'

describe 'CooSClient', ->

    it 'loads the CooS MW client', (done) ->
        io = new IOMock()
        coos = new coosmw.Coos(io, '192.168.0.1:3000')
        should.exist(coos)
        done()

    it 'requests a collaboration', (done) ->
        coos = new coosme.Coos(io, '0.0.0.0')
        
class IOMock
    connect: (uri)->
        console.log "ioMock.connect: #{uri}"


