_ = require 'underscore-plus'
{$, WorkspaceView} = require 'atom'
CommandPalette = require '../lib/simple-flake8-view'

describe "CommandPalette", ->
  [palette] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = null

    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      activationPromise = atom.packages.activatePackage("simple-flake8")

      atom.workspaceView.attachToDom().focus()
      atom.workspaceView.trigger 'simple-flake8:toggle'

    waitsForPromise ->
      activationPromise

    runs ->
      palette = atom.workspaceView.find('.simple-flake8').view()

  afterEach ->
    atom.workspaceView.remove()

  describe "when simple-flake8:toggle is triggered on the root view", ->
    it "shows a list of all valid command descriptions, names, and keybindings for the previously focused element", ->
      keyBindings = atom.keymap.findKeyBindings(atom.workspaceView.getActiveView())
      for eventName, description of atom.workspaceView.getActiveView().events()
        eventLi = palette.find("[data-event-name='#{eventName}']")
        if description
          expect(eventLi).toExist()
          expect(eventLi.find('span')).toHaveText(description)
          expect(eventLi.find('span').attr('title')).toBe(eventName)
          for binding in keyBindings when binding.command == eventName
            expect(eventLi.find(".key-binding:contains(#{_.humanizeKeystroke(binding.keystrokes)})")).toExist()
        else
          expect(eventLi).not.toExist()

    it "displays all commands registerd on the window", ->
      editorEvents = atom.workspaceView.getActiveView().events()
      windowEvents = $(window).events()
      expect(_.isEmpty(windowEvents)).toBeFalsy()
      for eventName, description of windowEvents
        eventLi = palette.list.children("[data-event-name='#{eventName}']")
        description = editorEvents[eventName] unless description
        if description
          expect(eventLi).toExist()
          expect(eventLi.find('span')).toHaveText(description)
          expect(eventLi.find('span').attr('title')).toBe(eventName)
        else
          expect(eventLi).not.toExist()

    it "focuses the mini-editor and selects the first command", ->
      expect(palette.filterEditorView.isFocused).toBeTruthy()
      expect(palette.find('.event:first')).toHaveClass 'selected'

    it "clears the previous mini editor text", ->
      palette.filterEditorView.setText('hello')
      palette.trigger 'simple-flake8:toggle'
      atom.workspaceView.trigger 'simple-flake8:toggle'
      expect(palette.filterEditorView.getText()).toBe ''

  describe "when simple-flake8:toggle is triggered on the open command palette", ->
    it "focus the root view and detaches the command palette", ->
      expect(palette.hasParent()).toBeTruthy()
      palette.trigger 'simple-flake8:toggle'
      expect(palette.hasParent()).toBeFalsy()
      expect(atom.workspaceView.getActiveView().isFocused).toBeTruthy()

  describe "when the command palette is cancelled", ->
    it "focuses the root view and detaches the command palette", ->
      expect(palette.hasParent()).toBeTruthy()
      palette.cancel()
      expect(palette.hasParent()).toBeFalsy()
      expect(atom.workspaceView.getActiveView().isFocused).toBeTruthy()

  describe "when an command selection is confirmed", ->
    it "detaches the palette, then focuses the previously focused element and emits the selected command on it", ->
      eventHandler = jasmine.createSpy('eventHandler').andReturn(false)
      activeEditor = atom.workspaceView.getActiveView()
      {eventName} = palette.items[5]
      activeEditor.preempt eventName, eventHandler

      palette.confirmed(palette.items[5])

      expect(activeEditor.isFocused).toBeTruthy()
      expect(eventHandler).toHaveBeenCalled()
      expect(palette.hasParent()).toBeFalsy()

  describe "when no element has focus", ->
    it "uses the root view as the element to display and trigger events for", ->
      atom.workspaceView.trigger 'simple-flake8:toggle'
      $(':focus').blur()
      atom.workspaceView.trigger 'simple-flake8:toggle'
      keyBindings = atom.keymap.findKeyBindings(atom.workspaceView.getActiveView())
      for eventName, description of atom.workspaceView.events()
        eventLi = palette.list.children("[data-event-name='#{eventName}']")
        if description
          expect(eventLi).toExist()
          expect(eventLi.find('span')).toHaveText(description)
          expect(eventLi.find('span').attr('title')).toBe(eventName)
          for binding in keyBindings when binding.command is eventName
            expect(eventLi.find(".key-binding:contains(#{_.humanizeKeystroke(binding.keystrokes)})")).toExist()
        else
          expect(eventLi).not.toExist()

  describe "when the body has focus", ->
    it "uses the root view as the element to display and trigger events for", ->
      atom.workspaceView.trigger 'simple-flake8:toggle'
      $(document.body).focus()
      atom.workspaceView.trigger 'simple-flake8:toggle'
      keyBindings = atom.keymap.findKeyBindings(atom.workspaceView.getActiveView())
      for eventName, description of atom.workspaceView.events()
        eventLi = palette.list.children("[data-event-name='#{eventName}']")
        if description
          expect(eventLi).toExist()
          expect(eventLi.find('span')).toHaveText(description)
          expect(eventLi.find('span').attr('title')).toBe(eventName)
          for binding in keyBindings when binding.command is eventName
            expect(eventLi.find(".key-binding:contains(#{_.humanizeKeystroke(binding.keystrokes)})")).toExist()
        else
          expect(eventLi).not.toExist()
