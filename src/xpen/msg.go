package xpen
import (
  "encoding/json"
  //log "github.com/cihub/seelog"
)


// 用户信息
type User struct {
  Nick    string
  Email   string
}

// 消息
type Message struct {
  Content   string
  Time      string
  User      User
}

// 消息列表
type Msg struct {
  Messages []Message
  Users []User
  Source User
}
// json
func (m Msg) toJson() (string, error) {
  b, err := json.Marshal(m)
  if err != nil{
    return "", err
  }
  return string(b), nil
}

// 读取消息
func ReadMsg(str string) Msg{
  var s Msg
  json.Unmarshal([]byte(str), &s)
  return s
}
