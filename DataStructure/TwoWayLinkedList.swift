//
//  TwoWayLinkedList.swift
//  Le
//
//  Created by Chen,Yalun on 2019/6/17.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

class TwoWayLinkedList<T: Equatable> {
    // 元素没有找到
    private let ELEMENT_NOT_FOUND = -1
    fileprivate var first: Node<T>?
    fileprivate var last: Node<T>?
    fileprivate var count: Int = 0
    
    init(_ ele: T) {
        first = Node(ele: ele, prev: nil, next: nil)
        last = first
        count += 1
    }
    
    // 结点类
    fileprivate class Node<T> {
        var ele: T
        var prev: Node<T>?
        var next: Node<T>?
        init(ele: T, prev: Node?, next: Node?) {
            self.ele = ele
            self.prev = prev
            self.next = next
        }
    }
    
    // 索引所在元素获取
    func get(_ index: Int) -> T {
        checkBounds(index)
        return node(index).ele
    }
    
    // 在某索引处插入元素
    func insert(_ item: T, _ index: Int) {
        if index < 0 || index > count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
        if index == count {
            let prev = last
            let newNode = Node(ele: item, prev: prev, next: nil)
            last = newNode
            prev?.next = newNode
            if index == 0 {
                first = last
            }
        } else {
            let next = node(index)
            let prev = next.prev
            let newNode = Node(ele: item, prev: prev, next: next)
            next.prev = newNode
            prev?.next = newNode
            if newNode.prev == nil {
                first = newNode
            }
        }
        count += 1
    }
    
    // 追加元素
    func append(_ item: T) {
        insert(item, count)
    }
    
    // 移除某索引的元素
    func remove(_ index: Int) {
        checkBounds(index)
        let old = node(index)
        let prev = old.prev
        let next = old.next
        if next == nil {
            last = prev
        } else {
            next?.prev = prev
        }
        
        if prev == nil {
            first = next
        } else {
            prev?.next = next
        }
        count -= 1
    }
    
    // 获取某元素所在索引
    func indexOf(_ item: T) -> Int {
        var node = first
        var idx = 0
        while node != nil {
            if node!.ele == item {
                return idx
            }
            node = node!.next
            idx += 1
        }
        return ELEMENT_NOT_FOUND
    }
    
    // 清空所有元素
    func clear() {
        // 打破循环引用
        var first = self.first
        while first != nil {
            first?.prev = nil
            first = first?.next
        }
        self.first = nil
        self.last = nil
        count = 0
    }
    
    // 打印
    func desc() {
        var node = first
        var str = ""
        for idx in 0..<count {
            if idx == 0 {
                str += "first:\(node!.ele),"
            }
            if node!.next != nil {
                str += " [\(node!.ele), \(node!.next!.ele)]"
            } else {
                str += " [\(node!.ele), nil]"
            }
            
            if node != nil {
                str += ","
            }
            
            if idx == count - 1 {
                str += " last:\(node!.ele)"
            }
            node = node!.next
            
        }
        print(str)
    }
    
    // 获取索引所在的结点
    fileprivate func node(_ index: Int) -> Node<T> {
        checkBounds(index)
        if index < count >> 1 {
            // 在前半部分查找
            var node = self.first
            for _ in 0..<index {
                node = node?.next
            }
            return node!
        } else {
            // 在后半部分查找
            var node = self.last
            for _ in (index + 1..<count).reversed() {
                node = node?.prev
            }
            return node!
        }
    }
    
    // 索引越界检查
    fileprivate func checkBounds(_ index: Int) {
        if index < 0 || index >= count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
    }
}



class TwoWayCircularLinkedList<T: Equatable>: TwoWayLinkedList<T> {
    override func insert(_ item: T, _ index: Int) {
        if index < 0 || index > count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
        if index == count {
            let prev = last
            let newNode = Node(ele: item, prev: prev, next: first)
            last = newNode
            prev?.next = newNode
            if index == 0 {
                first = last
                last?.next = newNode
            }
            first?.prev = newNode
        } else {
            let next = node(index)
            let prev = next.prev
            let newNode = Node(ele: item, prev: prev, next: next)
            next.prev = newNode
            prev?.next = newNode
            if index == 0 {
                // 首位插入元素
                first = newNode
            }
        }
        count += 1
    }
    
    override func remove(_ index: Int) {
        checkBounds(index)
        let old: Node? = node(index)
        var prev = old!.prev
        var next = old!.next
        if count == 1 && index == 0 {
            // 只有一个元素
            prev = nil
            next = nil
            old?.next = nil
            old?.prev = nil
        }
        if index == 0 {
            first = next
        }
        if index == count - 1 {
            last = prev
        }
        prev?.next = next
        next?.prev = prev
        count -= 1
    }
    
    override func clear() {
        // 打破循环引用
        var first = self.first
        for idx in 0..<count {
            first?.prev = nil
            first = first?.next
            if idx == count - 1 {
                first?.next = nil
            }
        }
        self.first = nil
        self.last = nil
        count = 0
    }
}



// 测试数据
class PersonNode: Equatable {
    var age: Int
    init(_ age: Int) {
        self.age = age
    }
    
    static func ==(a: PersonNode, b: PersonNode) -> Bool {
        return a.age == b.age
    }
    
    deinit {
        print("已经销毁, age: \(self.age)")
    }
}

/*
 var pList = TwoWayLinkedList(PersonNode(1))
 pList.append(PersonNode(3))
 pList.append(PersonNode(4))
 pList.insert(PersonNode(5), 1)
 pList.desc()
 pList.clear()
 
 var pList = TwoWayLinkedList(1)
 pList.append(2)
 pList.append(3)
 pList.insert(4, 0)
 pList.remove(0)
 pList.remove(0)
 pList.remove(0)
 pList.remove(3)
 pList.desc()
 pList.clear()
 */

/*
 var s = TwoWayCircularLinkedList(8)
 s.append(2)
 s.desc()
 s.clear()
 s.append(3)
 s.desc()
 s.clear()
 s.insert(0, 0)
 s.insert(1, 1)
 s.insert(3, 2)
 s.insert(2, 1)
 s.desc()
 s.clear()
 //s.append(PersonNode(3))
 s.desc()
 s.append(2)
 s.insert(11, 1)
 s.append(3)
 s.append(4)
 s.desc()
 s.remove(2)
 s.remove(0)
 s.remove(0)
 s.remove(0)
 s.desc()
 */





