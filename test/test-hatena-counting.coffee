# coffeelint: disable=max_line_length
Helper = require 'hubot-test-helper'
assert = require 'power-assert'

describe 'hatena-counting', ->
  room = null

  beforeEach ->
    helper = new Helper('../src/scripts/hatena-counting.coffee')
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  it 'help', ->
    helps = room.robot.helpCommands()
    assert.deepEqual helps, [
      'hubot counting - List registered counter images'
      'hubot counting [add|register] <url> - Register counter'
      'hubot counting [del|delete] <url> - Delete registered counter'
      'hubot counting list - List registered counter urls'
      'hubot counting periods - List configured periods'
    ]
