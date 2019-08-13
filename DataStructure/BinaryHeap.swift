//
//  BinaryHeap.swift
//  Le
//
//  Created by Chen,Yalun on 2019/8/13.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

protocol Heap  {
    associatedtype T
    var size: Int { get set }
    // 是否为空
    func isEmpty() -> Bool
    // 清空
    func clear()
    // 添加元素
    func add(_ ele: T)
    // 获取堆顶元素
    func get() -> T
    // 删除堆顶元素
    func remove() -> T
    // 删除堆顶元素的同时插入一个新元素
    func replace(_ ele: T) -> T?
}



class BinaryHeap<T: Comparable>: Heap {
    // 使用nil作为占位
    private var list: [T?]
    // 元素数量
    internal var size = 0
    // 默认10个元素
    private let DEFAULT_CAPACITY = 10
    
    // 构造器
    init(_ capaticy: Int) {
        let capaticy = capaticy < DEFAULT_CAPACITY ? DEFAULT_CAPACITY : capaticy
        list = [T?](repeating: nil, count: capaticy)
    }
    
    // 数组扩容
    private func ensureCapacity(_ count: Int) {
        if count > list.count {
            var oldList = self.list
            // 扩容1.5倍
            let newCapacity = oldList.count + oldList.count >> 1
            self.list = [T?](repeating: nil, count: newCapacity)
            for idx in 0..<size {
                self.list[idx] = oldList[idx]
            }
        }
    }
    
    // 是否为空
    func isEmpty() -> Bool {
        return size == 0
    }
    
    // 清空
    func clear() {
        for idx in 0..<size {
            list[idx] = nil
        }
        size = 0
    }
    
    // 添加元素
    func add(_ ele: T) {
        ensureCapacity(size + 1)
        list[size] = ele
        size += 1
        siftUp(size - 1)
    }
    
    // 获取堆顶元素
    func get() -> T {
        if self.isEmpty() {
            fatalError("堆为空, 无法删除")
        }
        return list[0]!
    }
    
    // 删除堆顶元素
    func remove() -> T {
        if self.isEmpty() {
            fatalError("堆为空, 无法删除")
        }
        size -= 1
        let first = list[0]!
        list[0] = list[size]
        list[size] = nil
        siftDown(0);
        return first
    }
    
    // 删除堆顶元素的同时插入一个新元素
    func replace(_ ele: T) -> T? {
        if self.isEmpty() {
            fatalError("堆为空, 无法删除")
        }
        var root: T?
        if (size == 0) {
            list[0] = ele
            size += 1
        } else {
            root = list[0];
            list[0] = ele;
            siftDown(0);
        }
        return root;
    }
    
    // 建堆
    func heapify(_ eles: [T]) {
        size = eles.count
        for idx in 0..<eles.count {
            list[idx] = eles[idx]
        }
        // 自上而下的上滤O(nlogn)
        /*
         for idx in 0..<size {
         siftUp(idx)
         }
         */
        
        // 自下而上的上滤O(n)
        for idx in (0...size >> 1).reversed() {
            siftDown(idx)
        }
    }
    
    // index位置的元素下滤
    private func siftDown(_ idx: Int) {
        let ele = list[idx]!
        var idx = idx
        while idx < size >> 1 {
            // 左结点
            var childIdx = idx << 1 + 1
            var child = list[childIdx]!
            // 右结点索引
            let rightIdx = childIdx + 1
            // 如果右结点存在, 则取出左右结点中较大的一个
            if rightIdx < size && list[rightIdx]! > child {
                childIdx = rightIdx
                child = list[childIdx]!
            }
            // 如果自己不小于较大子结点, 停止下滤
            if ele >= child {
                break
            }
            // 交换自己与较大子结点的位置
            list[idx] = child
            idx = childIdx
        }
        list[idx] = ele
    }
    
    // index位置的元素上滤
    private func siftUp(_ idx: Int) {
        var idx = idx
        let ele = list[idx]!
        while idx > 0 {
            let parentIdx = (idx - 1) >> 1
            let parent = list[parentIdx]!
            if parent >= ele {
                // 父结点不小于自己, 停止上滤
                break
            }
            // 交换自己与父结点的位置
            list[idx] = parent
            idx = parentIdx
        }
        list[idx] = ele
    }
    
    func desc() {
        print(list)
    }
}

/*
let b = BinaryHeap<Int>(10)
b.heapify([2, 7, 26, 25, 43, 2, 4, 4, 21, 4])
b.desc()
b.clear()
b.add(2)
assert(b.get() == 2)
b.add(7)
assert(b.get() == 7)
b.add(26)
assert(b.get() == 26)
b.add(25)
assert(b.get() == 26)
b.add(19)
assert(b.get() == 26)
b.add(37)
assert(b.get() == 37)
b.add(1)
assert(b.get() == 37)
b.add(90)
assert(b.get() == 90)
b.add(3)
assert(b.get() == 90)
b.add(36)
assert(b.get() == 90)
_ = b.remove()
assert(b.get() == 37)
_ = b.remove()
assert(b.get() == 36)
_ = b.remove()
assert(b.get() == 26)
_ = b.remove()
assert(b.get() == 25)
_ = b.remove()
assert(b.get() == 19)
_ = b.remove()
assert(b.get() == 7)
*/
/*
 上滤
 1、当插入一个新元素时，放在最末尾。
 2、若有父节点，将插入节点和父节点比较，如果插入节点大于父节点，交换位置。
 3、重复2，直至插入节点不小于父节点或者没有父节点，上滤结束。
 
 下滤
 1、删除首元素，将最后一个元素移到首节点。
 2、若有孩子，则比较该节点和最大孩子的值，若小于最大孩子的值，与最大的孩子互换位置。
 3、重复2，直至该节点的值大于最大孩子的值或者没有孩子，下滤结束，堆序性得以满足。
 */

