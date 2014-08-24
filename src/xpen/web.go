package xpen

import (
  "fmt"
  "os"
  "io"
  "../utils"
  "code.google.com/p/go.net/websocket"
  "code.google.com/p/go-uuid/uuid"
  log "github.com/cihub/seelog"
  "net/http"
  "html/template"
  "unsafe"
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
        mUsers.Users = append(mUsers.Users,
        User{Nick: u.Nick, Email: u.Email})
      }
    }
    mUsers.Pointer = fmt.Sprintf("%d", unsafe.Pointer(w))
    if err = websocket.JSON.Send(w, mUsers); err != nil {
      log.Error("不能发送消息到客户端")
      break
    }
  }
}

// 初始化聊天记录
func initHandler(ws *websocket.Conn, user User, msg Msg) {
  log.Debug(unsafe.Pointer(ws))
  var err error
  var m Msg
  m.Command = "chat"
  m.Messages = messages
  m.Pointer = fmt.Sprintf("%d", unsafe.Pointer(ws))
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

// 登出
func logoutHandler(ws *websocket.Conn, user User, msg Msg) {
  log.Debugf("用户登出，用户:%s", user.Nick)
  msg.Source.Nick = ""
  onlines[ws] = msg.Source
  usersHandler()
}

// 聊天
func chatHandler(ws *websocket.Conn, user User, msg Msg) {
  log.Debugf("用户: %s 发来消息:%s", user.Nick, msg.Messages)
  log.Debug(unsafe.Pointer(ws))
  var err error
  if len(msg.Messages) == 0 {
    return
  }
  msg.Messages[0].Time = utils.Now()
  msg.Messages[0].User = user
  msg.Pointer = fmt.Sprintf("%d", unsafe.Pointer(ws))
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
// 查找用户
func findUser(p string) (User, *websocket.Conn) {
  for w, u := range onlines {
    if len(u.Nick) > 0{
      if p == fmt.Sprintf("%d", unsafe.Pointer(w)){
        return u, w
      }
    }
  }
  return User{Nick: "未知用户", Email: "xx@xx"}, nil
}
// 发送文件下载 TODO 需要知道谁发送的
func sendFile(p string, url string, name string){
  var msg Msg
  user, ws := findUser(p)
  msg.Messages = append(msg.Messages, Message{
    Content: "<a target=\"_blank\" href=\"" + url + "\">" + name + "</a>",
    Time: utils.Now(),
    User: user,
  })
  msg.Command = "chat"
  msg.Source = user
  chatHandler(ws, user, msg)
}

// 接收ws请求
func wsServer(ws *websocket.Conn) {
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
  log.Infof("path: %s", r.URL.Path)
  staticHandler := http.FileServer(http.Dir("./static/"))
  staticHandler.ServeHTTP(w, r)
}

// 生成上传文件名，及URL地址
func uploadFile(name string) (string, string, error) {
  url := "up/" + uuid.New()
  path := "./static/" + url
  err := os.MkdirAll(path, os.ModePerm)
  path = path + "/" + name
  url = url + "/" + name
  return path, url, err
}

// 文件上传请求
func uploadServer(w http.ResponseWriter, r *http.Request){
  log.Debugf("method: %s", r.Method) //获取请求的方法
  if r.Method == "GET" {// 显示错误信息
    log.Debug("显示错误信息")
    NotFound404(w, r)
  }else{
    r.ParseMultipartForm(32 << 20)
    file, handler, err := r.FormFile("file")
    if err != nil {
      log.Errorf("read uploadfile: %s", err)
      return
    }
    defer file.Close()
    fmt.Fprintf(w, "%v", "ok")
    //TODO
    fname, url, mkerr := uploadFile(handler.Filename)
    if mkerr != nil {
      log.Errorf("目录操作无权限: %s", err)
      return
    }
    f, err := os.OpenFile(fname , os.O_WRONLY | os.O_CREATE, 0666)
    if err != nil {
      log.Errorf("copy uploadfile: %s", err)
      return
    }
    defer f.Close()
    io.Copy(f, file)
    sendFile(r.FormValue("pointer"), url, handler.Filename)
  }
}

// 404
func NotFound404(w http.ResponseWriter, r *http.Request) {
  log.Error("页面找不到")   //记录错误日志
  t, _ := template.ParseFiles("tmpl/404.html")  //解析模板文件
  ErrorInfo := "页面未找到" //获取当前用户信息
  t.Execute(w, ErrorInfo)  //执行模板的merger操作
}
//运行WEB服务
func RunWeb() {
  log.Info("启动WEB服务")
  http.HandleFunc("/", staticServer)
  http.HandleFunc("/upload", uploadServer)
  http.Handle("/ws", websocket.Handler(wsServer))
  err := http.ListenAndServe(":8080", nil) //设置监听的端口
  if err != nil {
    log.Error("监听错误: ", err)
  }
}
