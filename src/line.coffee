{Adapter, TextMessage} = require 'hubot'
request = require 'request'
lineDefaultEP = 'https://trialbot-api.line.me/v1/events'

class Line extends Adapter
  send: (envelope, strings...) ->
    data = JSON.stringify({
      "to": [envelope.user.name],
      "toChannel": 1383378250,
      "eventType": "138311608800106203",
      "content":{
        "contentType": 1,
        "toType": 1,
        "text": strings.join('\n')
      }
    })
    console.log(data)
    # using request module to use FIXIE PROXY
    proxyopt = {}
    proxyopt = {'proxy': process.env.FIXIE_URL} if process.env.FIXIE_URL
    customRequest = request.defaults(proxyopt)
    customRequest.post
      url: @lineEndpoint,
      headers: {
        'X-Line-ChannelID': @channelId,
        'X-Line-ChannelSecret': @channelSecret,
        'X-Line-Trusted-User-With-ACL': @channelMid,
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: data
    , (err, response, body) ->
      throw err if err
      if response.statusCode is 200
        console.log "success"
        console.log body
      else
        console.log "response error: #{response.statusCode}"
        console.log body

  run: ->
    @endpoint = process.env.HUBOT_ENDPOINT ? '/hubot/incoming'
    @lineEndpoint = process.env.LINE_ENDPOINT_URL ? lineDefaultEP
    @channelId = process.env.LINE_CHANNEL_ID
    @channelSecret = process.env.LINE_CHANNEL_SECRET
    @channelMid = process.env.LINE_CHANNEL_MID
    unless @channelId?
      @robot.logger.emergency "LINE_CHANNEL_ID is required"
      process.exit 1
    unless @channelSecret?
      @robot.logger.emergency "LINE_CHANNEL_SECRET is required"
      process.exit 1
    unless @channelMid?
      @robot.logger.emergency "LINE_CHANNEL_MID is required"
      process.exit 1
    @robot.router.post @endpoint, (req, res) =>
      console.log("callback body: " + JSON.stringify(req.body))
      # TODO check signature
      results = req.body.result
      for result in results
        if result.eventType != "138311609000106303"
          console.log("EventType is not 'Received message'. Skipping..")
          res.send 201
          return
        {from, text, contentType} = result.content
        if contentType isnt 1
          console.log("ContentType is not 'text'. Skipping..")
          res.send 201
          return
        console.log("from: " + from)
        console.log("text: " + text)
        user = @robot.brain.userForId from, room: 'room'
        @receive new TextMessage(user, text, 'messageId')
        res.send 201
    @emit 'connected'

module.exports.use = (robot) ->
  new Line(robot)
