//
//  ArrayList.swift
//  Le
//
//  Created by Chen,Yalun on 2019/6/17.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

class ArrayList<T: Equatable> {
    // 元素数量(只读)
    private(set) var count: Int = 0
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
    
    // 是否为空
    func isEmpty() -> Bool {
        return count == 0
    }
    
    // 插入元素
    func insert(_ item: T, _ index: Int) {
        if index < 0 || index > count {
            // 越界
            fatalError("索引有误, 已经越界")
        }
        ensureCapacity()
        for idx in (index...count).reversed() {
            elements[idx + 1] = elements[idx]
        }
        count += 1
        elements[index] = item
    }
    
    // 追加元素
    func append(_ item: T) {
        insert(item, count)
    }
    
    // 获取索引所在元素
    func get(_ index: Int) -> T {
        checkBounds(index)
        return elements[index]!
    }
    
    // 设置元素
    func set(_ item: T, _ index: Int) {
        checkBounds(index)
        elements[index] = item
    }
    
    // 移除元素
    func remove(_ index: Int) -> T {
        let ele = get(index)
        for idx in index..<count {
            elements[idx] = elements[idx + 1]
        }
        elements[count - 1] = nil
        count -= 1
        return ele
    }
    
    // 清空元素
    func clear() {
        for idx in 0..<count {
            elements[idx] = nil
        }
        count = 0
    }
    
    // 是否包含某个元素
    func contains(_ item: T) -> Bool {
        // item 不可能为nil
        return indexOf(item) != ELEMENT_NOT_FOUND
    }
    
    // 获取某个元素对应的索引
    private func indexOf(_ item: T) -> Int {
        // 这里的item不可能为nil
        for idx in 0..<count {
            if elements[idx]! == item {
                return idx
            }
        }
        return ELEMENT_NOT_FOUND
    }
    
    // 数组扩容
    private func ensureCapacity() {
        if count > elements.count >> 1 {
            var elements = self.elements
            // 扩容1.5倍
            let newCapacity = elements.count + elements.count >> 1
            self.elements = [T?](repeating: nil, count: newCapacity)
            for idx in 0..<count {
                self.elements[idx] = elements[idx]
            }
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

/*
var list = ArrayList<Int>(5)
// 是否为空
list.isEmpty()
// 追加元素
list.append(1)
// 插入元素
list.insert(2, 1)
// 移除元素
list.remove(0)
// 取值
list.get(0)
// 设置
list.set(12, 0)
// 包含某个元素
list.contains(2)
*/

/*
 实现过程中几个需要注意的点:
 1. 在indexOf()函数中，元素使用`==`判等，需要遵守Equatable协议
 2. 数组的扩容中，使用位运算符可以避免产生浮点数
 3. 由于Swift中可选类型的存在，可以使用nil来占位。当然，在set()、append()等函数中，由于类型确定也省略了外界传参时对空值的判断
 */

