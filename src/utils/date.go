package utils

import "time"

const (
  NOW_FORMAT = "2006-01-02 15:04:05"
  DATE_FORMAT = "2006-01-02"
  TIME_FORMAT = "15:04:05"
)

// 当前日期时间
func Now() string {
  return time.Now().Format(NOW_FORMAT)
}

// 当前日期
func NowDate() string {
  return time.Now().Format(DATE_FORMAT)
}

// 当前时间
func NowTime() string {
  return time.Now().Format(TIME_FORMAT)
}
