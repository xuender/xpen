package utils

func InSlice(s []string, o string) bool{
  for i:=0; i<len(s); i++{
    if o == s[i]{
      return true
    }
  }
  return false
}
