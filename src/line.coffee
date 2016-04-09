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
    # using request module to use FIXIE PROXY
    proxyopt = {} ? {'proxy': process.env.FIXIE_URL}
    customRequest = request.defaults(proxyopt)
    customRequest.post
      url: @lineEndpoint,
      headers: {
        'X-Line-ChannelID': @channelId,
        'X-Line-ChannelSecret': @channelSecret,
        'X-Line-Trusted-User-With-ACL': @channelMid,
        'Content-Type': 'application/json; charset=UTF-8'
      },
      json: true,
      body: data
    , (err, response, body) ->
      throw err if err
      if response.statusCode is 200
        console.log body
      else
        console.log "response error: #{response.statusCode}"

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
      console.log(req.body)
      results = req.body.result
      for result in results
        {from, text} = result.content
        console.log(from)
        console.log(text)
        user = @robot.brain.userForId from, room: 'room'
        @receive new TextMessage(user, text, 'messageId')
        res.send 201
    @emit 'connected'

module.exports.use = (robot) ->
  new Line(robot)
