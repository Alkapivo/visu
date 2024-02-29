///@package io.alkapivo.visu.editor.ui

///@param {VisuEditor} _editor
function VETitleBar(_editor) constructor {

  ///@type {VisuEditor}
  editor = Assert.isType(_editor, VisuEditor)

  ///@type {UIService}
  uiService = Assert.isType(this.editor.uiService, UIService)

  ///@type {Map<String, Containers>}
  containers = new Map(String, UI)

  ///@private
  ///@param {UIlayout} parent
  ///@return {UILayout}
  factoryLayout = function(parent) {
    return new UILayout(
      {
        name: "title-bar",
        nodes: {
          file: {
            name: "title-bar.file",
            x: function() { return this.context.x() + this.margin.left },
            y: function() { return 0 },
            width: function() { return 48 },
          },
          edit: {
            name: "title-bar.edit",
            x: function() { return this.context.nodes.file.right()
              + this.margin.left },
            y: function() { return 0 },
            width: function() { return 48 },
          },
          view: {
            name: "title-bar.view",
            x: function() { return this.context.nodes.edit.right()
              + this.margin.left },
            y: function() { return 0 },
            width: function() { return 48 },
          },
          help: {
            name: "title-bar.help",
            x: function() { return this.context.nodes.view.right()
              + this.margin.left },
            y: function() { return 0 },
            width: function() { return 48 },
          },
          event: {
            name: "title-bar.event",
            x: function() { return this.context.nodes.timeline.left() 
              - this.width() - this.margin.right },
            y: function() { return 0 },
            width: function() { return 20 },
          },
          timeline: {
            name: "title-bar.timeline",
            x: function() { return this.context.nodes.brush.left() 
              - this.width() - this.margin.right },
            y: function() { return 0 },
            width: function() { return 20 },
          },
          brush: {
            name: "title-bar.brush",
            x: function() { return this.context.x() + this.context.width()
               - this.width() - this.margin.right },
            y: function() { return 0 },
            width: function() { return 20 },
          }
        }
      }, 
      parent
    )
  }

  ///@private
  ///@param {UIlayout} parent
  ///@return {Map<String, UI>}
  factoryContainers = function(parent) {
    static factoryTextButton = function(json) {
      return Struct.appendRecursiveUnique(
        {
          type: UIButton,
          layout: json.layout,
          label: { text: json.text },
          options: json.options,
          callback: Struct.getDefault(json, "callback", function() { }),
          updateArea: Callable.run(UIUtil.updateAreaTemplates.get("applyLayout")),
          onMouseHoverOver: function(event) {
            this.backgroundColor = ColorUtil.fromHex(this.backgroundColorSelected).toGMColor()
          },
          onMouseHoverOut: function(event) {
            this.backgroundColor = ColorUtil.fromHex(this.backgroundColorOut).toGMColor()
          },
        },
        VEStyles.get("ve-title-bar").menu,
        false
      )
    }

    static factoryCheckboxButton = function(json) {
      return Struct.appendRecursiveUnique(
        {
          type: UICheckbox,
          layout: json.layout,
          spriteOn: json.spriteOn,
          spriteOff: json.spriteOff,
          store: json.store,
          updateArea: Callable.run(UIUtil.updateAreaTemplates.get("applyLayout")),
        },
        VEStyles.get("ve-title-bar").checkbox,
        false
      )
    }

    var controller = this
    var layout = this.factoryLayout(parent)
    return new Map(String, UI, {
      "ve-title-bar": new UI({
        name: "ve-title-bar",
        state: new Map(String, any, {
          "background-color": ColorUtil.fromHex(VETheme.color.primary).toGMColor(),
          "store": controller.editor.store,
        }),
        controller: controller,
        layout: layout,
        updateArea: Callable.run(UIUtil.updateAreaTemplates.get("applyLayout")),
        render: Callable.run(UIUtil.renderTemplates.get("renderDefault")),
        items: {
          "button_ve-title-bar_file": factoryTextButton({
            text: "New",
            layout: layout.nodes.file,
            options: new Array(),
            callback: function() {
              Beans.get(BeanVisuController).newProjectModal
                .send(new Event("open").setData({
                  layout: new UILayout({
                    name: "display",
                    x: function() { return 0 },
                    y: function() { return 0 },
                    width: function() { return GuiWidth() },
                    height: function() { return GuiHeight() },
                  }),
                }))
            }
          }),
          "button_ve-title-bar_edit": factoryTextButton({
            text: "Save",
            layout: layout.nodes.edit,
            options: new Array(),
            callback: function() {
              var path = FileUtil.getPathToSaveWithDialog({ 
                description: "Visu track file",
                filename: "manifest", 
                extension: "visu",
              })

              if (path == null) {
                return
              }

              global.__VisuTrack.saveProject(path)
            }
          }),
          "button_ve-title-bar_view": factoryTextButton({
            text: "Load",
            layout: layout.nodes.view,
            options: new Array(),
            callback: function() {
              var manifest = FileUtil.getPathToOpenWithDialog({ 
                description: "Visu track file",
                filename: "manifest", 
                extension: "visu"
              })

              if (!FileUtil.fileExists(manifest)) {
                return
              }

              var controller = Beans.get(BeanVisuController)
              controller.gridRenderer.clear()
              controller.editor.send(new Event("close"))
              controller.trackService.send(new Event("close-track"))
              controller.videoService.send(new Event("close-video"))
              controller.gridService.send(new Event("clear-grid"))
              controller.playerService.send(new Event("clear-player"))
              controller.shroomService.send(new Event("clear-shrooms"))
              controller.bulletService.send(new Event("clear-bullets"))
              controller.lyricsService.send(new Event("clear-lyrics"))
              controller.particleService.send(new Event("clear-particles"))
              Beans.get(BeanTextureService).send(new Event("free"))
              
              controller.send(new Event("load", {
                manifest: manifest,
                autoplay: false
              }))
            }
          }),
          /*
          "button_ve-title-bar_help": factoryTextButton({
            text: "Help",
            layout: layout.nodes.help,
            options: new Array(),
          }),
          */
          "button_ve-title-bar_event": factoryCheckboxButton({
            layout: layout.nodes.event,
            spriteOn: { name: "texture_ve_title_bar_icons", frame: 0 },
            spriteOff: { name: "texture_ve_title_bar_icons", frame: 0, alpha: 0.5 },
            store: { key: "render-event" },
          }),
          "button_ve-title-bar_timeline": factoryCheckboxButton({
            layout: layout.nodes.timeline,
            spriteOn: { name: "texture_ve_title_bar_icons", frame: 1 },
            spriteOff: { name: "texture_ve_title_bar_icons", frame: 1, alpha: 0.5 },
            store: { key: "render-timeline" },
          }),
          "button_ve-title-bar_brush": factoryCheckboxButton({
            layout: layout.nodes.brush,
            spriteOn: { name: "texture_ve_title_bar_icons", frame: 2 },
            spriteOff: { name: "texture_ve_title_bar_icons", frame: 2, alpha: 0.5 },
            store: { key: "render-brush" },
          }),
        },
      }),
    })
  }

  ///@type {EventPump}
  dispatcher = new EventPump(this, new Map(String, Callable, {
    "open": function(event) {
      this.containers = this.factoryContainers(event.data.layout)
      containers.forEach(function(container, key, uiService) {
        uiService.send(new Event("add", {
          container: container,
          replace: true,
        }))
      }, this.uiService)
    },
    "close": function(event) {
      var context = this
      this.containers.forEach(function (container, key, uiService) {
        uiService.send(new Event("remove", { 
          name: key, 
          quiet: true,
        }))
      }, this.uiService).clear()
    },
  }))

  ///@param {Event} event
  ///@return {?Promise}
  send = function(event) {
    return this.dispatcher.send(event)
  }

  ///@return {VETitleBar}
  update = function() { 
    this.dispatcher.update()
    return this
  }
}