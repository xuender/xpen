package xpen

import (
  //"fmt"
  "code.google.com/p/go.net/websocket"
  log "github.com/cihub/seelog"
  "net/http"
)
// 接收ws请求
func echo(ws *websocket.Conn) {
  var err error
  for {
    var reply string
    if err = websocket.Message.Receive(ws, &reply); err != nil {
      log.Error("不能重复连接")
      break
    }
    log.Debug("接收信息: ", reply)
    msg := "返回:  " + reply
    log.Debug("发送客户端: ", msg)
    if err = websocket.Message.Send(ws, msg); err != nil {
      log.Error("Can't send")
      break
    }
  }
}

func staticServer(w http.ResponseWriter, r *http.Request) {
  r.ParseForm() //解析参数，默认是不会解析的
  log.Info("path: ", r.URL.Path)
  staticHandler := http.FileServer(http.Dir("./static/"))
  staticHandler.ServeHTTP(w, r)
}

//运行WEB服务
func RunWeb() {
  log.Info("启动WEB服务")
  http.HandleFunc("/", staticServer)
  http.Handle("/ws", websocket.Handler(echo))
  err := http.ListenAndServe(":8080", nil) //设置监听的端口
  if err != nil {
    log.Error("ListenAndServe: ", err)
  }
}
