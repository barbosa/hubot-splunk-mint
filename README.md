hubot-splunk-mint
=================
Access data from [Splunk Mint](http://mint.splunk.com) (former BugSense) via hubot.


## Installation

Add **hubot-splunk-mint** to your `package.json` file:

```javascript
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-scripts": ">= 2.4.2",
  "hubot-splunk-mint": "*"
}
```

Add **hubot-splunk-mint** to your `external-scripts.json` file:

```javascript
[
  "hubot-splunk-mint"
]
```

Run `npm install`

## Configuration

In order to use **hubot-splunk-mint**, you need to set two environment variables:

- `HUBOT_SPLUNK_KEY`: Your SplunkMint API key. It can be found [here](https://mint.splunk.com/account).
- `HUBOT_SPLUNK_PROJECT_KEY`: Your project API key

## Sample Interaction

```
Hubot> hubot how many crashes?
Hubot> Shell: There are 0 crashes today. Yesterday, they were 2.
Hubot> hubot how many sessions?
Hubot> Shell: There are 17 sessions today. Yesterday, they were 29.
Hubot> hubot how many uniques?
Hubot> Shell: There are 12 unique_users today. Yesterday, they were 20.
```
