//
//  Queue.swift
//  Le
//
//  Created by Chen,Yalun on 2019/6/20.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

// 因为频繁地在开头末尾添加删除元素所以使用链表实现
// 又因为双向链表有头指针和尾指针而单向链表只有头指针所以使用双向链表实现(减少遍历)
class Queue<T: Equatable> {
    private var list: TwoWayLinkedList<T> = TwoWayLinkedList()
    
    // 元素数量
    func size() -> Int {
        return list.count
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return list.isEmpty()
    }
    
    // 入队
    func enQueue(_ item: T) {
        list.append(item)
    }
    
    // 出队
    func deQueue() -> T {
        return list.remove(0)
    }
    
    // 获取队头元素
    func front() -> T? {
        return list.first?.ele
    }
    
    // 清空所有元素
    func clear() {
        list.clear()
    }
    
    // 打印元素
    func desc() {
        list.desc()
    }
}



// 使用栈实现队列
// 原理:
// 1. 入队时, 把元素放入inStack中
// 2. 出队时, 如果outStack为空, 则把inStack中的全部栈顶元素依次放到outStack中, 返回outStack的栈顶元素, 否则, 直接返回outStack的栈顶元素
class Queue_UseStack<T: Equatable> {
    // 维护两个栈
    private var inStack: Stack<T> = Stack()
    private var outStack: Stack<T> = Stack()
    
    // 元素数量
    func size() -> Int {
        return inStack.size() + outStack.size()
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return size() == 0
    }
    
    // 入队
    func enQueue(_ item: T) {
        inStack.push(item)
    }
    
    // 出队
    func deQueue() -> T {
        if outStack.isEmpty() {
            while inStack.isEmpty() == false {
                outStack.push(inStack.pop())
            }
        }
        return outStack.pop()
    }
    
    // 获取队头元素
    func front() -> T? {
        if outStack.isEmpty() {
            while inStack.isEmpty() == false {
                outStack.push(inStack.pop())
            }
        }
        return outStack.top()
    }
    
    // 清空所有元素
    func clear() {
        inStack.clear()
        outStack.clear()
    }
}

/*
 var queue = Queue<Int>()
 queue.enQueue(1)
 queue.enQueue(2)
 queue.enQueue(3)
 queue.deQueue()
 print(queue.front())
 queue.enQueue(3)
 print(queue.front())
 queue.desc()
 */

/*
 let que = Queue_UseStack<Int>()
 que.enQueue(1)
 que.deQueue()
 que.enQueue(2)
 que.enQueue(3)
 que.deQueue()
 print(que.front())
 */
