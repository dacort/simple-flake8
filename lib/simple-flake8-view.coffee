_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom'

module.exports =
class SimpleFlake8View extends SelectListView
  @activate: ->
    new SimpleFlake8View

  keyBindings: null

  initialize: ->
    super

    @addClass('simple-flake8 overlay from-top')
    atom.workspaceView.command 'simple-flake8:toggle', => @toggle()

  getFilterKey: ->
    'eventDescription'

  toggle: ->
    if @hasParent()
      @cancel()
    else
      @attach()

  attach: ->
    @storeFocusedElement()

    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
      @eventElement = @previouslyFocusedElement
    else
      @eventElement = atom.workspaceView
    @keyBindings = atom.keymap.findKeyBindings(target: @eventElement[0])

    events = []
    for eventName, eventDescription of _.extend($(window).events(), @eventElement.events())
      events.push({eventName, eventDescription}) if eventDescription
    events = _.sortBy(events, 'eventDescription')
    @setItems(events)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  viewForItem: ({eventName, eventDescription}) ->
    keyBindings = @keyBindings
    $$ ->
      @li class: 'event', 'data-event-name': eventName, =>
        @div class: 'pull-right', =>
          for binding in keyBindings when binding.command is eventName
            @kbd _.humanizeKeystroke(binding.keystrokes), class: 'key-binding'
        @span eventDescription, title: eventName

  confirmed: ({eventName}) ->
    @cancel()
    @eventElement.trigger(eventName)
