# Description:
#   Access data from Splunk Mint (former BugSense) via hubot.
#
# Dependencies:
#   "coffee-script": "^1.8.0"
#
# Configuration:
#   HUBOT_SPLUNK_KEY - Your SplunkMint API key
#   HUBOT_SPLUNK_PROJECT_KEYS - Your project API keys. Format must be:
#     HUBOT_SPLUNK_PROJECT_KEYS="my_project=12aed3,other=341bc21"
#
# Commands:
#   hubot splunk my_project crashes - Show the crashes count for "my_project"
#   hubot splunk my_project sessions - Show the sessions count for "my_project"
#   hubot splunk my_project uniques - Show the unique_users count for "my_project"
#
# Notes:
#   Your SplunkMint API key can be found at https://mint.splunk.com/account
#   Your project API key can be found at https://mint.splunk.com/dashboard
#
# Author:
#   Gustavo Barbosa <gustavocsb@gmail.com>

ensureConfig = (out) ->
  out "Error: Splunk app key is not specified" unless process.env.HUBOT_SPLUNK_KEY
  out "Error: Splunk project keys is not specified" unless process.env.HUBOT_SPLUNK_PROJECT_KEYS
  return false unless (process.env.HUBOT_SPLUNK_KEY and process.env.HUBOT_SPLUNK_PROJECT_KEYS)

apiURL = (path) ->
  return "https://www.bugsense.com/api/v1#{path}"

toSingular = (actionName) ->
    map = {"crashes": "crash", "sessions": "session", "uniques": "unique"}
    return map[actionName]

module.exports = (robot) ->

  ensureConfig console.log

  robot.respond /splunk (.*) (crashes|sessions|uniques)\??$/i, (msg) ->

    projectName = msg.match[1]
    projectKey = ''

    aliases = process.env.HUBOT_SPLUNK_PROJECT_KEYS.split ","
    availableProjects = []
    for alias in aliases
      [aliasName, aliasKey] = alias.split "="
      availableProjects.push aliasName
      if aliasName == projectName
        projectKey = aliasKey

    if projectKey == ''
      msg.send "Sorry. I don't know the project #{projectName}."
      msg.send "Options are: #{availableProjects}"
      return

    metric = msg.match[2]

    if metric == 'uniques'
      metric = 'unique_users'

    robot.http(apiURL("/project/#{projectKey}/analytics.json"))
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
        todayCount = parseInt(data[metric][2], 10)
        yesterdayCount = parseInt(data[metric][1], 10)

        if todayCount == 1
            todayMessage = "There is 1 #{toSingular(metric)} today."
        else
            todayMessage = "There are #{todayCount} #{metric} today."

        if yesterdayCount == 1
            yesterdayMessage = "Yesterday, it was 1."
        else
            yesterdayMessage = "Yesterday, they were #{yesterdayCount}."

        msg.reply "#{todayMessage} #{yesterdayMessage}"
