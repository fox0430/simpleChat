import websocket
import strutils, asyncnet, asyncdispatch

stdout.write "name: "
let name = readLine(stdin)
stdout.write "host: "
let host = readLine(stdin)
let ws = waitFor newAsyncWebsocketClient(host, Port(8080), path = "/")
echo "connected!"

proc ping() {.async.} =
  while true:
    stdout.write "input: "
    var mes = readLine(stdin)
    let sendData = [name, ": ", mes]
    await sendText(ws, sendData.join(""))

proc read() {.async.} =
  while true:
    let (opcode, data) = await ws.readData()
    echo "(opcode: ", opcode, ", data: ", data, ")"

asyncCheck read()
asyncCheck ping()
runForever()
