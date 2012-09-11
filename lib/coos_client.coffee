#
# 02/08/2012
# @mariohct
#
# CooS Client Javascript
#

# Constants
UPDATE_TIME = 1

class Coos
    about =
        Version: 0.1
        Author: "Mario H.C.T."
        Twitter: "@mariohct"
        Created: 2012

    constructor: (@io, coosServer, @updateTime) ->
        if not @updateTime?
            @updateTime = UPDATE_TIME
        if not @io?
            throw 'Socket-io is required'
        if not coosServer?
            throw 'Server Address should be defined'
        else
            @socket = io.connect(coosServer)


   
    requestCollaboration: (deviceId, latLng, payload, @initiatorCallback) =>
        console.log "requestCollaboration"
        @socket.emit 'CollaborationRequest', payload

        @socket.on 'CollaborationResponse', initiatorCallback


    registerAsParticipant: (deviceId, locationCallback, @participantCallback) =>
        console.log "registerAsParticipant"
        @socket.on 'CollaborationRequest', (collaborationRequestDTO) =>
            console.log "CoosClient received a CollaborationRequest"
            @participantCallback collaborationRequestDTO, (payload, bid) =>
                #console.log "Anonymous reply to CollaborationRequest called"
                collaborationBid =
                        deviceId: @deviceId
                        collaborationRequestId: collaborationRequestDTO.collaborationRequestId
                        payload: payload
                        bid: bid

                @socket.emit 'CollaborationResponse', collaborationBid

        #@socket.on('newTask', (data) ->
        #    console.log "CoosClient received data"
        #    participantCallback(data)
        #)

root = exports ? this
root.Coos = Coos
                                
