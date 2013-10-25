(function() {
  var buildGuid, positions, s4, socket, uuid;

  s4 = function() {
    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  };

  buildGuid = function() {
    return s4() + s4() + "-" + s4() + "-" + s4() + "-" + s4() + "-" + s4() + s4() + s4();
  };

  uuid = buildGuid();

  positions = {};

  socket = io.connect("/");

  socket.once("connect", function() {
    return $(function() {
      var adjustBackground, onRemoteMouseConnect, onRemoteMouseMove;
      adjustBackground = function() {
        var colorStr, colors, pVals;
        pVals = Object.values(positions);
        colors = pVals.map(function(p) {
          return p.x + p.y;
        });
        colors = colors.reduce(function(a, b) {
          return a + b;
        }) * 16 ^ 10 / (colors.length * $("body").width());
        colorStr = colors.toString(16);
        return $("body").css({
          "background": "#" + ("0".repeat(6 - colorStr.length)) + colorStr
        });
      };
      onRemoteMouseMove = function(data) {
        if ($(".pointer-" + data.uuid).length === 0) {
          onRemoteMouseConnect(data);
        }
        positions[data.uuid] = data;
        adjustBackground();
        return $(".pointer-" + data.uuid).css({
          position: "absolute",
          left: data.x,
          top: data.y
        });
      };
      onRemoteMouseMove = onRemoteMouseMove.throttle(30);
      onRemoteMouseConnect = function(data) {
        var $el;
        console.log("connected a remote");
        $el = $("<div class='remote-pointer pointer-" + data.uuid + "'></div>");
        return $("body").append($el);
      };
      console.log("connected");
      socket.on("mousemove", onRemoteMouseMove);
      socket.on("mouseconnect", onRemoteMouseConnect);
      return $(document).on("mousemove", function(e) {
        var data;
        data = {
          x: e.pageX,
          y: e.pageY,
          uuid: uuid
        };
        socket.emit("mousemove", data);
        positions[data.uuid] = data;
        return adjustBackground();
      });
    });
  });

}).call(this);
