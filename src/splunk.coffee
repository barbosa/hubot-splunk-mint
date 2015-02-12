projectKey = ''
apiKey = ''

module.exports = (robot) ->
  robot.respond /how many (crashes|sessions|uniques)\??/i, (msg) ->

    metric = msg.match[1]

    if metric == 'uniques'
      metric = 'unique_users'

    robot.http("https://www.bugsense.com/api/v1/project/#{projectKey}/analytics.json")
      .header('X-BugSense-Auth-Token', '#{apiKey}')
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        if err
          msg.send "Couldn't find anything :("
          return

        data = JSON.parse(body)
        today = data[metric][2]
        yesterday = data[metric][1]

        msg.reply "There are #{today} #{metric} today. Yesterday, they were #{yesterday}."
