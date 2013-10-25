# here's standard Express server declaration
express = require("express")
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
io.set('log level', 1)
app.engine('jade', require('jade').__express)
app.use('/', express.static(__dirname + '/public'))
server.listen process.env.PORT || 8880

# configuring assets pipeline (full definition of config options see below)
app.use require("asset-pipeline")(
  
  # reference to a server itself (used in views rendering)
  server: app
  
  # directory with your stylesheets or client-side scripts
  assets: "./assets"
  
  # directory for cache
  cache: "./cache"
)

app.get '/', (req, res) ->
  res.render 'index.jade'


io.sockets.on "connection", (socket) ->

  socket.on "mousemove", (data) ->
    socket.broadcast.emit "mousemove", data

