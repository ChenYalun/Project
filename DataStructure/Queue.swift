//
//  Queue.swift
//  Le
//
//  Created by Chen,Yalun on 2019/6/20.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//


/// 队列
/*
 因为频繁地在开头末尾添加删除元素所以使用链表实现
 又因为双向链表有头指针和尾指针而单向链表只有头指针所以使用双向链表实现(减少遍历)
 */
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





/// 使用栈实现队列
/*
 原理:
 1. 入队时, 把元素放入inStack中
 2. 出队时, 如果outStack为空, 则把inStack中的全部栈顶元素依次放到outStack中, 返回outStack的栈顶元素, 否则, 直接返回outStack的栈顶元素
 */
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
 let que = Queue_UseStack<Int>()
 que.enQueue(1)
 que.deQueue()
 que.enQueue(2)
 que.enQueue(3)
 que.deQueue()
 print(que.front())
 */




/// 循环队列
/*
 使用动态数组实现, 且各接口优化到O(1)时间复杂度
 要点:
 1. 有一个指向队头元素的索引frontIndex, 必不可少
 2. 接口索引与真实索引的互换: 真实索引 = (frontIndex + index) % elements.count
 3. 入队
 */
class CircleQueue<T: Equatable> {
    // 元素数量
    private var count: Int = 0
    // 指向队头的索引
    private var frontIndex: Int = 0
    // 使用nil作为占位
    private var elements: [T?]
    // 默认10个元素
    private let DEFAULT_CAPACITY = 10
    private let ELEMENT_NOT_FOUND = -1
    
    // 构造器, 初始化容量为capaticy的数组
    init(_ capaticy: Int) {
        let capaticy = capaticy < DEFAULT_CAPACITY ? DEFAULT_CAPACITY : capaticy
        elements = [T?](repeating: nil, count: capaticy)
    }
    
    // 元素数量
    func size() -> Int {
        return count
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return count == 0
    }
    
    // 入队
    func enQueue(_ item: T) {
        ensureCapacity(count + 1)
        elements[index(count)] = item
        count += 1
    }
    
    // 出队
    func deQueue() -> T {
        let ele = elements[frontIndex]
        if ele == nil {
            fatalError("队列为空")
        }
        elements[frontIndex] = nil
        // 不是frontIndex += 1, 要考虑frontIndex == elements.count但是elements有空闲位置的情况
        // 这时应该是frontIndex = (frontIndex + 1) % elements.count, 也就是index(1)
        frontIndex = index(1)
        count -= 1
        return ele!
    }
    
    // 获取队头元素
    func front() -> T? {
        return elements[frontIndex]
    }
    
    // 清空所有元素
    func clear() {
        for idx in 0..<elements.count {
            elements[idx] = nil
        }
        frontIndex = 0
        count = 0
    }
    
    // 数组扩容
    private func ensureCapacity(_ capacity: Int) {
        // 不需要扩容
        if elements.count >= capacity {
            return
        }
        var elements = self.elements
        // 扩容1.5倍
        let newCapacity = elements.count + elements.count >> 1
        var newElements = [T?](repeating: nil, count: newCapacity)
        for idx in 0..<count {
            newElements[idx] = elements[index(idx)]
        }
        self.elements = newElements
        frontIndex = 0
    }
    
    // 获取索引对应真实索引
    private func index(_ index: Int) -> Int {
        return (frontIndex + index) % elements.count
    }
    
    // 打印元素
    func desc() {
        print("frontIndex: \(frontIndex)" + " eles: \(elements)")
    }
}
/*
var cq = CircleQueue<Int>(10)
cq.enQueue(1)
cq.enQueue(2)
cq.enQueue(3)
cq.deQueue()
cq.deQueue()
cq.deQueue()
cq.desc()
cq.enQueue(11)
cq.enQueue(12)
cq.enQueue(13)
cq.enQueue(21)
cq.enQueue(22)
cq.enQueue(23)
cq.enQueue(33)
cq.enQueue(42)
cq.enQueue(43)
cq.enQueue(44)
cq.enQueue(54)
cq.desc()
cq.deQueue()
cq.deQueue()
cq.desc()
*/





/// 双端队列
/*
 两端都可以入队和出队
 */
class DoubleEndedQueue<T: Equatable> {
    private var list: TwoWayLinkedList<T> = TwoWayLinkedList()
    
    // 元素数量
    func size() -> Int {
        return list.count
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return list.isEmpty()
    }
    
    // 从队头入队
    func enQueueFront(_ item: T) {
        list.insert(item, 0)
    }
    
    // 从队尾入队
    func enQueueRear(_ item: T) {
        list.append(item)
    }
    
    // 从队头出队
    func deQueueFront() -> T {
        return list.remove(0)
    }
    
    // 从队尾出队
    func deQueueRear() -> T {
        return list.remove(list.count - 1)
    }
    
    // 获取队头元素
    func front() -> T? {
        return list.first?.ele
    }
    
    // 获取队尾元素
    func rear() -> T? {
        return list.last?.ele
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

/*
let deq = DoubleEndedQueue<Int>()
deq.enQueueFront(1)
deq.enQueueFront(2)
deq.enQueueRear(8)
deq.enQueueRear(9)
deq.desc()
deq.clear()
deq.enQueueFront(1)
deq.enQueueFront(2)
deq.deQueueFront()
deq.enQueueRear(8)
deq.enQueueRear(9)
deq.deQueueRear()
deq.desc()
*/




// 循环双端队列
class CircleDoubleEndedQueue<T: Equatable> {
    // 元素数量
    private var count: Int = 0
    // 指向队头的索引
    private var frontIndex: Int = 0
    // 使用nil作为占位
    private var elements: [T?]
    // 默认10个元素
    private let DEFAULT_CAPACITY = 10
    private let ELEMENT_NOT_FOUND = -1
    
    // 构造器, 初始化容量为capaticy的数组
    init(_ capaticy: Int) {
        let capaticy = capaticy < DEFAULT_CAPACITY ? DEFAULT_CAPACITY : capaticy
        elements = [T?](repeating: nil, count: capaticy)
    }
    
    // 元素数量
    func size() -> Int {
        return count
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return count == 0
    }
    
    // 从队头入队
    func enQueueFront(_ item: T) {
        ensureCapacity(count + 1)
        frontIndex = index(-1)
        elements[frontIndex] = item
        count += 1
    }
    
    // 从队尾入队
    func enQueueRear(_ item: T) {
        ensureCapacity(count + 1)
        elements[index(count)] = item
        count += 1
    }
    
    // 从队头出队
    func deQueueFront() -> T {
        if count <= 0 {
            fatalError("队列为空")
        }
        let ele = elements[frontIndex]
        elements[frontIndex] = nil
        frontIndex = index(1)
        count -= 1
        return ele!
    }
    
    // 从队尾出队
    func deQueueRear() -> T {
        if count <= 0 {
            fatalError("队列为空")
        }
        let ele = elements[index(count - 1)]!
        elements[index(count - 1)] = nil
        count -= 1
        return ele
    }
    
    // 获取队头元素
    func front() -> T? {
        return elements[frontIndex]
    }
    
    // 获取队尾元素
    func rear() -> T? {
        return elements[index(count - 1)]
    }
    
    // 清空所有元素
    func clear() {
        for idx in 0..<elements.count {
            elements[idx] = nil
        }
        frontIndex = 0
        count = 0
    }
    
    // 数组扩容
    private func ensureCapacity(_ capacity: Int) {
        // 不需要扩容
        if elements.count >= capacity {
            return
        }
        var elements = self.elements
        // 扩容1.5倍
        let newCapacity = elements.count + elements.count >> 1
        var newElements = [T?](repeating: nil, count: newCapacity)
        for idx in 0..<count {
            newElements[idx] = elements[index(idx)]
        }
        self.elements = newElements
        frontIndex = 0
    }
    
    // 获取索引对应真实索引
    private func index(_ index: Int) -> Int {
        var index = index
        index += frontIndex
        if index < 0 {
            return index + elements.count
        }
        //        return index % elements.count
        return index - (index >= elements.count ? elements.count : 0)
    }
    
    // 打印元素
    func desc() {
        print("frontIndex: \(frontIndex)" + ",eles: \(elements)")
    }
}

/*
var cdeq = CircleDoubleEndedQueue<Int>(10)
cdeq.clear()
cdeq.enQueueFront(1)
cdeq.deQueueFront()
cdeq.enQueueFront(1)
cdeq.enQueueFront(2)
cdeq.enQueueFront(3)
cdeq.deQueueFront()
cdeq.enQueueRear(9)
cdeq.enQueueRear(5)
cdeq.enQueueRear(4)
cdeq.deQueueRear()
cdeq.desc()
*/
