s4 = ->
  Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
buildGuid = ->
  s4() + s4() + "-" + s4() + "-" + s4() + "-" + s4() + "-" + s4() + s4() + s4()

uuid = buildGuid()

positions = {}

socket = io.connect("/") # TIP: .connect with no args does auto-discovery
socket.once "connect", -> $ -> # TIP: you can avoid listening on `connect` and listen on events directly too!

  adjustBackground = ->
    # console.log Object.values(positions)[0]
    pVals = Object.values(positions)
    colors = pVals.map((p) -> p.x + p.y)
    colors = colors.reduce((a,b) ->a+b) * 16^10 / ( colors.length * $("body").width() )
    colorStr = colors.toString(16)
    # console.log "##{"0".repeat(6 - colorStr.length)}#{colorStr}"
    $("body").css
      "background": "##{"0".repeat(6 - colorStr.length)}#{colorStr}"

  onRemoteMouseMove = (data) ->
    onRemoteMouseConnect(data) if $(".pointer-#{data.uuid}").length == 0
    # console.log data # data will be 'woot'
    positions[data.uuid] = data
    adjustBackground()
    $(".pointer-#{data.uuid}").css
      position: "absolute"
      left: data.x
      top: data.y

  onRemoteMouseMove = onRemoteMouseMove.throttle(30)

  onRemoteMouseConnect = (data) ->
    console.log "connected a remote"
    $el = $ "<div class='remote-pointer pointer-#{data.uuid}'></div>"
    $("body").append($el)


  console.log "connected"
  socket.on "mousemove", onRemoteMouseMove
  socket.on "mouseconnect", onRemoteMouseConnect

  $(document).on "mousemove", (e) ->
    data = x: e.pageX, y: e.pageY, uuid: uuid
    socket.emit "mousemove", data
    positions[data.uuid] = data
    adjustBackground()
