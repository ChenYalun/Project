//
//  OneWayLinkedList.swift
//  Le
//
//  Created by Chen,Yalun on 2019/6/17.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

class OneWayLinkedList<T: Equatable> {
    // 元素没有找到
    private let ELEMENT_NOT_FOUND = -1
    fileprivate var first: Node<T>?
    fileprivate var count: Int = 0
    
    init(_ firstEle: T?) {
        if firstEle == nil {
            first = nil
        } else {
            first = Node(ele: firstEle!, next: nil)
            count += 1
        }
    }
    
    // 便利构造
    convenience init() {
        self.init(nil)
    }
    
    // 结点类
    fileprivate class Node<T> {
        var ele: T
        var next: Node<T>?
        init(ele: T, next: Node?) {
            self.ele = ele
            self.next = next
        }
    }
    
    // 索引所在元素获取
    func get(_ index: Int) -> T {
        return node(index).ele
    }
    
    // 在某索引处插入元素
    func insert(_ item: T, _ index: Int) {
        if index < 0 || index > count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
        if index == 0 {
            let prev = first
            let newNode = Node(ele: item, next: prev)
            first = newNode
        } else {
            let prev = node(index - 1)
            let newNode = Node(ele: item, next: prev.next)
            prev.next = newNode
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
        if index == 0 {
            first = first?.next
        } else {
            let noe = node(index - 1)
            noe.next = noe.next?.next
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
        count = 0
        self.first = nil
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
            node = node!.next
            if node != nil {
                str += ","
            }
        }
        print(str)
    }
    
    // 获取索引所在的结点
    fileprivate func node(_ index: Int) -> Node<T> {
        checkBounds(index)
        var node = self.first
        for _ in 0..<index {
            node = node?.next
        }
        return node!
    }
    
    // 索引越界检查
    fileprivate func checkBounds(_ index: Int) {
        if index < 0 || index >= count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
    }
}



class OneWayCircularLinkedList<T: Equatable>: OneWayLinkedList<T> {
    override func insert(_ item: T, _ index: Int) {
        if index < 0 || index > count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
        if index == 0 {
            let prev = first
            let newNode = Node(ele: item, next: prev)
            if prev == nil {
                // 只有一个元素
                newNode.next = newNode
            }
            first = newNode
        } else {
            let prev = node(index - 1)
            // 处理添加到最后一个位置
            let fir = (index == count) ? first : prev.next
            let newNode = Node(ele: item, next: fir)
            prev.next = newNode
        }
        count += 1
    }
    
    override func remove(_ index: Int) {
        checkBounds(index)
        if index == 0 {
            let last = node(count - 1)
            // 对最后一个元素的处理
            first = (count - 1 == index) ? nil : first?.next
            last.next = first
        } else {
            let noe = node(index - 1)
            noe.next = noe.next?.next
        }
        count -= 1
    }
    
    override func clear() {
        let last = node(count - 1)
        // 打破循环引用
        last.next = nil
        // 调用父类
        super.clear()
    }
}

/*
var list = OneWayLinkedList(12)
list.clear()
list.append(2)
list.append(4)
list.insert(5, 1)
print("索引是:\(list.indexOf(1))")
print("元素是:\(list.get(1))")
list.desc()
 */

/*
var on = OneWayCircularLinkedList(1)
on.append(9)
on.append(7)
on.desc()
on.remove(2)
on.desc()
on.clear()
on.append(3)
on.append(5)
on.append(6)
*/
