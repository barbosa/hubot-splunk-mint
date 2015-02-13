# Based on hubot-trello, from jared barboza
# see https://github.com/hubot-scripts/hubot-trello/blob/master/src/trello.coffee

ensureConfig = (out) ->
  out "Error: Splunk app key is not specified" unless process.env.HUBOT_SPLUNK_KEY
  out "Error: Splunk project key is not specified" unless process.env.HUBOT_SPLUNK_PROJECT_KEY
  return false unless (process.env.HUBOT_SPLUNK_KEY and process.env.HUBOT_SPLUNK_PROJECT_KEY)

apiURL = (path) ->
  return "https://www.bugsense.com/api/v1#{path}"

module.exports = (robot) ->

  ensureConfig console.log

  robot.respond /how many (crashes|sessions|uniques)\??/i, (msg) ->

    metric = msg.match[1]

    if metric == 'uniques'
      metric = 'unique_users'

    robot.http(apiURL("/project/#{process.env.HUBOT_SPLUNK_PROJECT_KEY}/analytics.json"))
      .header("X-BugSense-Auth-Token", "#{process.env.HUBOT_SPLUNK_KEY}")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        if err
          msg.send err
          return

        if res.statusCode isnt 200
          msg.send "Bam! #{res.statusCode}: #{body}"
          return

        data = JSON.parse(body)
        today = data[metric][2]
        yesterday = data[metric][1]

        msg.reply "There are #{today} #{metric} today. Yesterday, they were #{yesterday}."
