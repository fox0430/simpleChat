import websocket, asynchttpserver, asyncnet, asyncdispatch

let server = newAsyncHttpServer()

proc cb(req: Request) {.async.} =
  let (ws, error) = await verifyWebsocketRequest(req)

  if ws.isNil:
    echo "WS negotiation failed: ", error
    await req.respond(Http400, "Websocket negotiation failed: " & error)
    req.client.close()
    return

  echo "connected!"
  while true:
    let (opcode, data) = await ws.readData()
    try:
      echo data

      if opcode == Opcode.Close:
        asyncCheck ws.close()
        let (closeCode, reason) = extractCloseData(data)
        echo "socket went away, close code: ", closeCode, ", reason: ", reason
      else: discard
    except:
      echo "encountered exception: ", getCurrentExceptionMsg()

waitFor server.serve(Port(8080), cb)
