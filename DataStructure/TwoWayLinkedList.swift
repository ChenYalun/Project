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
    private var first: Node<T>?
    private var last: Node<T>?
    private var count: Int = 0
    
    init(_ ele: T) {
        first = Node(ele: ele, prev: nil, next: nil)
        last = first
        count += 1
    }
    
    // 结点类
    private class Node<T> {
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
            } else if newNode.next == nil {
                last = newNode
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
        while node != nil {
            str += "\(node!.ele)"
            // str += "\(Unmanaged.passUnretained(node! as AnyObject).toOpaque())"
            node = node!.next
            if node != nil {
                str += ","
            }
        }
        
        // print("first:\(Unmanaged.passUnretained(first as AnyObject).toOpaque())," + "last:\(Unmanaged.passUnretained(last as AnyObject).toOpaque())," + str)
        print("first:\(first?.ele)," + "last:\(last?.ele)," + str)
    }
    
    // 获取索引所在的结点
    private func node(_ index: Int) -> Node<T> {
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
    private func checkBounds(_ index: Int) {
        if index < 0 || index >= count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
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
        print("已经销毁")
    }
}

/*
 var pList = TwoWayLinkedList(PersonNode(1))
 pList.append(PersonNode(3))
 pList.append(PersonNode(4))
 pList.insert(PersonNode(5), 1)
 pList.desc()
 pList.clear()
 */

/*
var list = TwoWayLinkedList(12)
list.clear()
list.append(2)
list.append(4)
list.insert(5, 1)
list.insert(15, 0)
list.append(42)
list.insert(7, 5)
list.insert(8, 5)
list.desc()
list.remove(0)
print("索引是:\(list.indexOf(4))")
print("元素是:\(list.get(1))")
list.desc()
*/
