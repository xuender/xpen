package xpen

import (
  //"fmt"
  "code.google.com/p/go.net/websocket"
  log "github.com/cihub/seelog"
  "net/http"
  "../utils"
)


// 在线用户
var onlines = make(map[*websocket.Conn]User)
var messages = utils.NewStack()

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
    _, ok := onlines[ws]
    if ok {
      //onlines[ws] = count + 1
    } else {
      //onlines[ws] = 1
      log.Debug("初始化, 在线用户:",len(onlines))
      user := User {
        Nick: "test1",
        Email: "xxxx@xxx",
      }
      onlines[ws] = user
      log.Debug(onlines)
      var mUsers Msg
      for _, u := range onlines{
        mUsers.Users = append(mUsers.Users, User{Nick: u.Nick, Email: u.Email})
      }
      for w, _ := range onlines{
        if err = websocket.JSON.Send(w, mUsers); err != nil {
          log.Error("不能发送消息到客户端")
          break
        }
      }
    }
    m := Message{
      Content: reply,
      Time: utils.Now(),
      User: onlines[ws],
    }
    messages.Push(m)
    if messages.Len() > 10{
      messages.Pop()
    }
    log.Debug("消息数量:%d", messages.Len())
    for w, u := range onlines{
      log.Debug("User:", u)
      if err = websocket.JSON.Send(w, m); err != nil {
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
