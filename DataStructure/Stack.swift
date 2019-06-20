//
//  Stack.swift
//  Le
//
//  Created by Chen,Yalun on 2019/6/20.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

// 使用动态数组实现(组合)
class Stack<T: Equatable> {
    // 设置容量默认为10, 可自动扩容
    private var list: ArrayList<T> = ArrayList(10)
    
    // 元素数量
    func size() -> Int {
        return list.count
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return list.isEmpty()
    }
    
    // 入栈
    func push(_ item: T) {
        list.append(item)
    }
    
    // 出栈
    func pop() -> T {
        return list.remove(size() - 1)
    }
    
    // 获取栈顶元素
    func top() -> T? {
        return size() == 0 ? nil : list.get(size() - 1)
    }
    
    // 清空所有元素
    func clear() {
        list.clear()
    }
}


/*
 let stack = Stack<Int>()
 stack.push(1)
 print(stack.top())
 stack.push(2)
 print(stack.top())
 stack.push(3)
 stack.clear()
 print(stack.top())
 stack.push(4)
 print(stack.top())
 stack.push(5)
 print(stack.top())
 stack.pop()
 print(stack.top())
 stack.pop()
 print(stack.top())
 */
