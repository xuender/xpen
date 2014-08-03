package utils

import "testing"

func TestDate(t *testing.T) {
  if len(Now()) != 19 {
    t.Errorf("Now()格式错误 %s", Now())
  }
  if len(NowDate()) != 10 {
    t.Errorf("NowDate()格式错误 %s", NowDate())
  }
  if len(NowTime()) != 8 {
    t.Errorf("NowTime()格式错误 %s", NowTime())
  }
}
