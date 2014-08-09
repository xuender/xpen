package xpen

import "testing"

func TestMsg(t *testing.T) {
	str := `{"messages":[
  {"content":"xxx","time":"2014", 
  "user":{"nick":"张三", "email":"xuender@gmail.com"}}
  ]}`
	msg := ReadMsg(str)
	if msg.Messages[0].Time != "2014" {
		t.Errorf("日期错误 %s", msg.Messages[0].Time)
	}
	// 消息装换JSON
	str, _ = msg.toJson()
	if len(str) < 10 {
		t.Errorf("JSON转换错误 %s", str)
	}
}
