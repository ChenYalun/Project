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
    private var first: Node<T>?
    private var count: Int = 0
    
    init(_ firstEle: T) {
        first = Node(ele: firstEle, next: nil)
        count += 1
    }
    
    // 结点类
    private class Node<T> {
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
        while node != nil {
            str += "\(node!.ele)"
            node = node!.next
            if node != nil {
                str += ","
            }
        }
        print(str)
    }
    
    // 获取索引所在的结点
    private func node(_ index: Int) -> Node<T> {
        checkBounds(index)
        var node = self.first
        for _ in 0..<index {
            node = node?.next
        }
        return node!
    }
    
    // 索引越界检查
    private func checkBounds(_ index: Int) {
        if index < 0 || index >= count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
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
 单向链表的结构图如下:
 
 */

