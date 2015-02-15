# Description:
#   Access data from Splunk Mint (former BugSense) via hubot.
#
# Dependencies:
#   "coffee-script": "^1.8.0"
#
# Configuration:
#   HUBOT_SPLUNK_KEY - Your SplunkMint API key
#   HUBOT_SPLUNK_PROJECT_KEY - Your project API key
#
# Commands:
#   hubot how many crashes in splunk - Show the crashes count
#   hubot how many sessions in splunk - Show the sessions count
#   hubot how many uniques in splunk - Show the unique_users count
#
# Notes:
#   Your SplunkMint API key can be found at https://mint.splunk.com/account
#   Your project API key can be found at https://mint.splunk.com/dashboard
#
# Author:
#   Gustavo Barbosa <gustavocsb@gmail.com>

ensureConfig = (out) ->
  out "Error: Splunk app key is not specified" unless process.env.HUBOT_SPLUNK_KEY
  out "Error: Splunk project key is not specified" unless process.env.HUBOT_SPLUNK_PROJECT_KEY
  return false unless (process.env.HUBOT_SPLUNK_KEY and process.env.HUBOT_SPLUNK_PROJECT_KEY)

apiURL = (path) ->
  return "https://www.bugsense.com/api/v1#{path}"

module.exports = (robot) ->

  ensureConfig console.log

  robot.respond /how many (crashes|sessions|uniques) in splunk\??$/i, (msg) ->

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
