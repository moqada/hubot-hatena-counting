# Description
#   Notify and Respond Count Up/Down images from Hatena Counting
#
# Commands:
#   hubot counting - List registered counter images
#   hubot counting list - List registered counter urls
#   hubot counting [add|register] <url> - Register counter
#   hubot counting [del|delete] <url> - Delete registered counter
#   hubot counting periods - List configured periods
#
# Configuration:
#   HUBOT_HATENA_COUNTING_GYAZO_TOKEN - Gyazo API Token
#   HUBOT_HATENA_COUNTING_COUNTDOWN_PERIODS - Notification periods for count down (ex. 0d,1d,2d,3d,4d,5d,10d,*/50d)
#   HUBOT_HATENA_COUNTING_COUNTUP_PERIODS - Notification periods for count up (ex. 100d,500d,*/1000d,*/1y)
#   HUBOT_HATENA_COUNTING_SCHEDULE - Notification schedule (ex. '0 9 * * *')
#   HUBOT_HATENA_COUNTING_ROOM - Target chat room id
#   HUBOT_HATENA_COUNTING_MESSAGE_NO_COUNTERS - Message of no counters
#   HUBOT_HATENA_COUNTING_MESSAGE_NO_PERIODS - Message of no periods
#
# Author:
#   moqada <moqada@gmail.com>
{Readable} = require 'stream'
cheerio = require 'cheerio'
Gyazo = require  'gyazo-api'
moment = require 'moment'
request = require 'superagent'
schedule = require 'node-schedule'
webshot = require 'webshot'

PREFIX = 'HUBOT_HATENA_COUNTING_'
GYAZO_TOKEN = process.env["#{PREFIX}GYAZO_TOKEN"]
COUNTUP_PERIODS = process.env["#{PREFIX}COUNTUP_PERIODS"] or ''
COUNTDOWN_PERIODS = process.env["#{PREFIX}COUNTDOWN_PERIODS"] or ''
SCHEDULE = process.env["#{PREFIX}SCHEDULE"]
ROOM = process.env["#{PREFIX}ROOM"]
MESSAGE_NO_COUNTERS = process.env["#{PREFIX}MESSAGE_NO_COUNTERS"] or 'No counters'
MESSAGE_NO_PERIODS = process.env["#{PREFIX}MESSAGE_NO_PERIODS"] or 'No periods'
STORE_KEY = 'hubot-hatena-counting:counters'


module.exports = (robot) ->

  periods =
    down: parsePeriods COUNTDOWN_PERIODS
    up: parsePeriods COUNTUP_PERIODS

  robot.respond /counting$/i, (res) ->
    counters = getCounters()
    if counters.length < 1
      return res.send MESSAGE_NO_COUNTERS
    sendCounters res, counters

  robot.respond /counting list$/i, (res) ->
    counters = getCounters()
    if counters.length < 1
      return res.send MESSAGE_NO_COUNTERS
    counters.forEach (url) -> res.send url

  robot.respond /counting periods$/i, (res) ->
    format = (periodList) ->
      if periodList.length < 1
        return MESSAGE_NO_PERIODS
      periodList.map (period) ->
        "- #{period.duration}#{period.type}#{if period.rootine then ' (rootine)' else ''}"
      .join '\n'
    res.send """
    CountUp:
    #{format(periods.up)}

    CountDown:
    #{format(periods.down)}
    """

  robot.respond /counting (?:add|register) (http:\/\/counting\.hatelabo\.jp\/count\/\w+)$/i, (res) ->
    url = res.match[1]
    success = addCounter url
    if success
      return res.send "Added: #{url}"
    res.send "Already added: #{url}"

  robot.respond /counting (?:del|delete) (http:\/\/counting\.hatelabo\.jp\/count\/[\w]+)$/i, (res) ->
    url = res.match[1]
    success = deleteCounter url
    if success
      return res.send "Deleted: #{url}"
    res.send "Not Registered: #{url}"


  sendCounters = (sender, counters) ->
    promise = Promise.resolve()
    counters.forEach (url) ->
      promise = promise
        .then -> getImageUrl(url)
        .then (image) -> sender.send image
        .then -> new Promise (r) -> setTimeout(r, 500)
        .catch (err) -> sender.send err


  addCounter = (url) ->
    if not robot.brain.get STORE_KEY
      robot.brain.set STORE_KEY, []
    memories = robot.brain.get(STORE_KEY)
    if url not in memories
      memories.push url
      return true
    return false


  getCounters = ->
    robot.brain.get(STORE_KEY) or []


  deleteCounter = (url) ->
    memories = getCounters()
    idx = memories.indexOf url
    if idx < 0
      return false
    robot.brain.set STORE_KEY, memories.splice idx, 1
    return true


  periodicSend = ->
    promise = Promise.resolve([])
    getCounters().forEach (url) ->
      promise = promise
        .then (ret) ->
          getInfo(url).then (info) -> ret.concat([{url, info}])
        .then (ret) ->
          new Promise (rs, rj) ->
            setTimeout ->
              rs(ret)
            , 500
    promise.then (results) ->
      targetCounters = results
        .filter ({url, info}) -> isTargetDay(info)
        .map ({url, info}) -> url
      sender = {send: (msg) -> robot.messageRoom ROOM, msg}
      sendCounters sender, targetCounters
    .catch (err) -> sender.send err

  do ->
    if not SCHEDULE
      return
    schedule.scheduleJob SCHEDULE, periodicSend


  isTargetDay = (info) ->
    method = if info.type is 'up' then 'subtract' else 'add'
    now = moment().startOf('d').toDate()
    date = moment(now)[method](info.days, 'd')
    return periods[info.type].some (period) ->
      duration = info.days
      if period.type is 'y'
        duration = Math.abs moment(now).diff date, 'y', true
      if period.rootine
        if duration % period.duration is 0
          return true
      else if duration is period.duration
        return true


getInfo = (url) ->
  new Promise (resolve, reject) ->
    request(url).end (err, res) ->
      if err
        return reject err
      $ = cheerio(res.text)
      content = $.find('meta[name="twitter:description"]').attr('content')
      matches = /(\d+)/.exec content
      days = parseInt matches and matches[1], 10
      if Number.isNaN days
        return reject(days)
      type = if content.indexOf('日目') >= 0 then 'up' else 'down'
      resolve {days, type}


getImageUrl = (url) ->
  new Promise (resolve, reject) ->
    stream = webshot(url, {captureSelector: '.main-count'})
    readable = new Readable().wrap(stream)
    readable.path = url
    new Gyazo(GYAZO_TOKEN).upload readable
      .then (res) ->
        resolve res.data.url
      .catch (err) ->
        reject err


parsePeriods = (pattern) ->
  pattern.split(',').filter (s) -> s.trim()
  .map (s) ->
    matches = /^(\*\/)?(\d+)([dy])/.exec s
    if not matches
      throw new Error('Invalid pattern')
    [rootine, duration, type] = matches.slice(1)
    duration = parseInt duration
    rootine = !!rootine
    return {rootine, duration, type}
