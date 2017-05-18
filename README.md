# hubot-hatena-counting

[![Greenkeeper badge](https://badges.greenkeeper.io/moqada/hubot-hatena-counting.svg)](https://greenkeeper.io/)

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Dependency Status][daviddm-image]][daviddm-url]
[![DevDependency Status][daviddm-dev-image]][daviddm-dev-url]
[![License][license-image]][license-url]

Notify and Respond Count Up/Down images from [Hatena Counting](http://counting.hatelabo.jp/).

:clock2: Support Scheduled notifications.

## Demo

![](https://i.gyazo.com/17581bce0c82fc146f23f4d99f7fd916.png)

## Installation

```
npm install @moqada/hubot-hatena-counting --save
```

Then add **@moqada/hubot-hatena-counting** to your `external-scripts.json`:

```json
["@moqada/hubot-hatena-counting"]
```

## Sample Interaction

```
User> hubot counting
Hubot>
https://i.gyazo.com/zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.png

User> hubot counting add http://counting.hatelabo.jp/count/xxxxxx
Hubot>
Added: http://counting.hatelabo.jp/count/xxxxxx

User> hubot counting list
Hubot>
http://counting.hatelabo.jp/count/yyyyyy
http://counting.hatelabo.jp/count/xxxxxx

User> hubot counting delete http://counting.hatelabo.jp/count/xxxxxx
Hubot>
Deleted: http://counting.hatelabo.jp/count/xxxxxx

User> hubot counting add http://counting.hatelabo.jp/count/xxxxxx
Hubot> Added: http://counting.hatelabo.jp/count/xxxxxx

User> hubot counting list
Hubot> http://counting.hatelabo.jp/count/xxxxxx

User> hubot counting periods
Hubot>
CountUp:
- 100d
- 500d
- 1000d (rootine)
- 1y (rootine)

CountDown:
- 0d
- 1d
- 2d
- 3d
- 4d
- 5d
- 10d
- 50d (rootine)
```

## Commands

```
hubot counting - List registered counter images
hubot counting list - List registered counter urls
hubot counting [add|register] <url> - Register counter
hubot counting [del|delete] <url> - Delete registered counter
hubot counting periods - List configured periods
```

## Configurations

```
HUBOT_HATENA_COUNTING_GYAZO_TOKEN - Gyazo API Token (requirement)
HUBOT_HATENA_COUNTING_COUNTDOWN_PERIODS - Notification periods for count down (ex. 0d,1d,2d,3d,4d,5d,10d,*/50d)
HUBOT_HATENA_COUNTING_COUNTUP_PERIODS - Notification periods for count up (ex. 100d,500d,*/1000d,*/1y)
HUBOT_HATENA_COUNTING_SCHEDULE - Notification schedule (ex. '0 9 * * *')
HUBOT_HATENA_COUNTING_ROOM - Target chat room id
HUBOT_HATENA_COUNTING_MESSAGE_NO_COUNTERS - Message of no counters
HUBOT_HATENA_COUNTING_MESSAGE_NO_PERIODS - Message of no periods
```

## Tips

### Garbled characters (文字化け)

Sometimes, generated images includes garbled characters.

You may fix this problem putting `.fonts` directory and font files into your Hubot repository.
More details, see [this article](http://d.hatena.ne.jp/osyo-manga/20130626/1372210417).

### Scheduled notification

You can automate to notify images on specific day.
you need to set following Configurations.

```
HUBOT_HATENA_COUNTING_COUNTDOWN_PERIODS='0d,1d,2d,3d,4d,5d,10d,*/50d'
HUBOT_HATENA_COUNTING_COUNTUP_PERIODS='100d,500d,*/1000d,*/1y'
HUBOT_HATENA_COUNTING_SCHEDULE='0 9 * * *'
HUBOT_HATENA_COUNTING_ROOM='<foo>@conference.<bar>.xmpp.slack.com'
```

This means are...

- Notify every 9 o'clock if there are target counters.
- Notify to room (`<foo>@conference.<bar>.xmpp.slack.com`).
- target counters are decided following conditions.
  - count down: that day, prev day, 2-5 days before, 10 days before, every 50 days
  - count up: 100 days, 500 days, every 1000 days, every 1 year

### Alias

[hubot-alias](https://github.com/dtaniwaki/hubot-alias) is useful scripts if you want to replace command (ex. `hubot counting` to `hubot 記念日`).

```
User> hubot alias 記念日=counting

User> hubot 記念日
Hubot>
https://i.gyazo.com/zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.png
```

## Related

Greatly inspired from [this article](http://blog.8arrow.org/entry/2016/01/13/183349).


[npm-url]: https://www.npmjs.com/package/@moqada/hubot-hatena-counting
[npm-image]: https://img.shields.io/npm/v/@moqada/hubot-hatena-counting.svg?style=flat-square
[travis-url]: https://travis-ci.org/moqada/hubot-hatena-counting
[travis-image]: https://img.shields.io/travis/moqada/hubot-hatena-counting.svg?style=flat-square
[daviddm-url]: https://david-dm.org/moqada/hubot-hatena-counting
[daviddm-image]: https://img.shields.io/david/moqada/hubot-hatena-counting.svg?style=flat-square
[daviddm-dev-url]: https://david-dm.org/moqada/hubot-hatena-counting#info=devDependencies
[daviddm-dev-image]: https://img.shields.io/david/dev/moqada/hubot-hatena-counting.svg?style=flat-square
[license-url]: http://opensource.org/licenses/MIT
[license-image]: https://img.shields.io/github/license/moqada/hubot-hatena-counting.svg?style=flat-square
