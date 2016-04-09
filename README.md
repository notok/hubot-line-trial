# hubot-line-trial

A [hubot](https://github.com/github/hubot) adaptor for
[line bot api trial](https://developers.line.me/bot-api/overview)

## Prepare

* Get line bot api trial account.
  * https://business.line.me/services/products/4/introduction
* Create bot account.
  * Set callback url like `https://<hubot hostname>:443/hubot/incoming`

## Install

```
npm install hubot-line-trial --save
```

## Configure

The adapter requires the following environment variables
to be defined prior to run a hubot instance.

Set with `export` command on Non-Heroku environment or
`heroku config:add` command on Heroku.

### Required environment variables

Check `Channel ID`, `Channel Secret`, `MID` on LINE developers page.

* `LINE_CHANNEL_ID` - The channel ID for bot
* `LINE_CHANNEL_SECRET` - The secret for bot
* `LINE_CHANNEL_MID` - The mid for bot

### Optional environment variables

* `FIXIE_URL` _default: none_ - This is automatically set when using with
  [fixie](https://elements.heroku.com/addons/fixie) on heroku
* `HUBOT_ENDPOINT` _default: /hubot/incoming_ - The path of
  incoming URL of hubot
* `LINE_ENDPOINT_URL` _default: `https://trialbot-api.line.me/v1/events`_ -
  endpoint for line bot api

## Run

After setting environment variables, run hubot with line-trial adapter.

```
bin/hubot -a line-trial
```

## License

The MIT License. See `LICENSE` file.
