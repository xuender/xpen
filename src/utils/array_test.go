package utils

import "testing"

func TestArray(t *testing.T) {
  //if !in_slice([]int{1,2,3}, 3) {
  //  t.Errorf("应该包含没有包含")
  //}
  if !InSlice([]string{"1","2","3"}, "3") {
    t.Errorf("应该包含没有包含")
  }
  //if in_slice([]int{1,2,3}, 5) {
  //  t.Errorf("错误的包含")
  //}
  if InSlice([]string{"1","2","3"}, "5") {
    t.Errorf("错误的包含")
  }
}
