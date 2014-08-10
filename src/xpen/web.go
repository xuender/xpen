package xpen

import (
	//"fmt"
	"../utils"
	"code.google.com/p/go.net/websocket"
	log "github.com/cihub/seelog"
	"net/http"
)

// 在线用户
var onlines = make(map[*websocket.Conn]User)
var messages []Message

// 刷新用户信息
func usersHandler() {
	var err error
	for w, _ := range onlines {
		var mUsers Msg
		mUsers.Command = "users"
		for ows, u := range onlines {
			if ows != w && len(u.Nick) > 0 {
				mUsers.Users = append(mUsers.Users, User{Nick: u.Nick, Email: u.Email})
			}
		}
		if err = websocket.JSON.Send(w, mUsers); err != nil {
			log.Error("不能发送消息到客户端")
			break
		}
	}
}

// 初始化聊天记录
func initHandler(ws *websocket.Conn, user User, msg Msg) {
	var err error
	var m Msg
	m.Command = "chat"
	m.Messages = messages
	if err = websocket.JSON.Send(ws, m); err != nil {
		log.Error("不能发送消息到客户端")
	}
}

// 登录
func loginHandler(ws *websocket.Conn, user User, msg Msg) {
	log.Debugf("用户登录，旧用户:%s, 新用户:%s", user.Nick, msg.Source.Nick)
	onlines[ws] = msg.Source
	usersHandler()
}
// 登录
func logoutHandler(ws *websocket.Conn, user User, msg Msg) {
	log.Debugf("用户登出，旧用户:%s", user.Nick)
	msg.Source.Nick = ""
	onlines[ws] = msg.Source
	usersHandler()
}

// 聊天
func chatHandler(ws *websocket.Conn, user User, msg Msg) {
	log.Debugf("用户: %s 发来消息:%s", user.Nick, msg.Messages)
	var err error
	if len(msg.Messages) == 0 {
		return
	}
	msg.Messages[0].Time = utils.Now()
	msg.Messages[0].User = user
	messages = append(messages, msg.Messages[0])
	if len(messages) > 10 { // 保留最后10条聊天记录
		messages = messages[1:11]
	}
  for w, u := range onlines {
    if len(u.Nick) > 0{
      log.Debugf("发送消息给:%s", u.Nick)
      if err = websocket.JSON.Send(w, msg); err != nil {
        log.Error("不能发送消息到客户端")
        break
      }
    }
  }
}

// 接收ws请求
func wsHandler(ws *websocket.Conn) {
  var err error
  for {
    var reply WsData
    //var reply string
    if err = websocket.JSON.Receive(ws, &reply); err != nil {
      delete(onlines, ws)
      log.Error("关闭连接, 在线用户:%d", len(onlines))
      usersHandler()
      break
    }
    log.Debugf("接收信息: %s", reply)
    user, ok := onlines[ws]
    if !ok {
      log.Debugf("初始化, 在线用户:%d", len(onlines))
      user = reply.Message.Source
      onlines[ws] = user
    }
    switch reply.Message.Command {
    case "login":
      loginHandler(ws, user, reply.Message)
    case "logout":
      logoutHandler(ws, user, reply.Message)
    case "chat":
      chatHandler(ws, user, reply.Message)
    case "init":
      initHandler(ws, user, reply.Message)
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
