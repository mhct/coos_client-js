#
# 03/05/2012
# @mariohct
#
# CooS Client API 
#
# Environment VARS
# EVENTS_SERVER = URL, events server url
#
io = require 'socket.io-client'
i = require('util').inspect


#
# Configuration variables
#
#socketUrl = process.env.EVENTS_SERVER || 'http://localhost:3000'

socket = null
isConnected = false
coosClient = null

class CoosEventsDispatcher
    constructor: (@deviceId, @socketUrl) ->
        console.log "Loading CoosEventsDispatcher, deviceID; #{@deviceId}"

    updateLocation: () =>
        currentLocation = @locationCallback.getCurrentLocation()
        if not (currentLocation? && currentLocation.length == 2)
            throw  "LocationCallback.getCurrentLocation() should return an array[Number, Number]"

        locationUpdateEvent =
                    deviceId: @deviceId
                    currentLocation:
                            latitude: currentLocation[0]
                            longitude: currentLocation[1]
                    payload: @locationCallback.getPayload() #TODO check payload size
        console.log i(locationUpdateEvent)

        @socket.emit "locationUpdate", locationUpdateEvent


    setupEventListeners: () =>
        @socket.on 'connect', =>
            console.log "Device: #{@deviceID} connected."

        @socket.on 'disconnect', =>
            console.log "#{@deviceID} disconnected."

        @socket.on 'connect_failed', =>
            console.log "#{@deviceID} connection failed."

        @socket.on 'error', =>
            console.log "Can not connect to CoosEventsServer #{socketUrl}"

        @socket.on 'collaboration_request', (data) =>
            console.log "collaboration request, #{data}"
            bid = @participationCallback.collaborationRequested data
            collaborationBid =
                        deviceId: @deviceId
                        collaborationRequestId: data.collaborationRequestId
                        payload: bid

            @socket.emit 'collaboration_bid', collaborationBid

        @socket.on 'collaboration_awarded', (data) =>
            console.log "collaboration awarded #{i(rideRequest)}"
            @participationCallback.collaborationAwarded data
           

    connect: () =>
        #io.set('transports', ['xhr-polling'])
        @socket = io.connect @socketUrl
        this.setupEventListeners()

    setParticipantCallback: (participantCb) =>
        @participationCallback = participantCb

    setInitiatorCallback: (initiatorCb) =>
        @initiatorCallback = initiatorCb

    setLocationCallback: (locationCb) =>
        @locationCallback = locationCb

    stop: =>
        @socket.disconnect()

    test: =>
        if @socket?
            now = new Date()
            @socket.emit "data", now


registerAsParticipant = (participantCb) ->
    coosClient.setParticipantCallback(participantCb)

registerAsInitiator = (initiatorCb) ->
    coosClient.setInitiatorCallback(initiatorCb)

registerLocationProvider = (locationCb) ->
    coosClient.setLocationCallback(locationCb)

initialize = (deviceId, socketUrl, tickInterval = 1000) ->
    coosClient = new CoosEventsDispatcher(deviceId, socketUrl)
    coosClient.connect()
    setInterval(coosClient.updateLocation, tickInterval)

    
stop = () ->
    coosClient.stop()

process.on 'exit', ->
    now = new Date()
    console.log "CoosClient unloaded"


exports.initialize = initialize # Synchronous call
exports.registerLocationProvider = registerLocationProvider
exports.registerAsInitiator = registerAsInitiator
exports.registerAsParticipant = registerAsParticipant
exports.stop = stop

