package utils

import "container/list"

// 堆栈
type Stack struct {
	list *list.List
}

// 新建堆栈
func NewStack() *Stack {
	list := list.New()
	return &Stack{list}
}

// 压栈
func (stack *Stack) Push(value interface{}) {
	stack.list.PushBack(value)
}

// 出栈
func (stack *Stack) Pop() interface{} {
	e := stack.list.Back()
	if e != nil {
		stack.list.Remove(e)
		return e.Value
	}
	return nil
}

// 顶端
func (stack *Stack) Peak() interface{} {
	e := stack.list.Back()
	if e != nil {
		return e.Value
	}
	return nil
}

// 堆栈长度
func (stack *Stack) Len() int {
	return stack.list.Len()
}

// 堆栈是否为空
func (stack *Stack) Empty() bool {
	return stack.list.Len() == 0
}
