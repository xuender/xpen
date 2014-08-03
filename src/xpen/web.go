package xpen

import (
  //"fmt"
  "code.google.com/p/go.net/websocket"
  log "github.com/cihub/seelog"
  "net/http"
)

type user struct {
  name     string
  email    string
  gravatar string
}
//var onlines map[*websocket.Conn]int
var onlines = make(map[*websocket.Conn]int)

// 接收ws请求
func wsHandler(ws *websocket.Conn) {
  var err error
  for {
    var reply string
    if err = websocket.Message.Receive(ws, &reply); err != nil {
      delete(onlines, ws)
      log.Error("关闭连接, 在线用户:",len(onlines))
      break
    }
    log.Debug("接收信息: ", reply)
    count, ok := onlines[ws]
    if ok {
      onlines[ws] = count + 1
      log.Debug("第%s次访问", count)
    } else {
      onlines[ws] = 1
      log.Debug("初始化, 在线用户:",len(onlines))
    }
    for w, u := range onlines{
      msg := "返回:  " + reply
      log.Debug("发送客户端: ", msg)
      log.Debug("User:", u)
      if err = websocket.Message.Send(w, msg); err != nil {
        log.Error("不能发送消息到客户端")
        break
      }
    }
  }
}

// 静态资源服务
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
  http.Handle("/ws", websocket.Handler(wsHandler))
  err := http.ListenAndServe(":8080", nil) //设置监听的端口
  if err != nil {
    log.Error("ListenAndServe: ", err)
  }
}
