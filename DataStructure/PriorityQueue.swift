//
//  PriorityQueue.swift
//  Le
//
//  Created by Chen,Yalun on 2019/8/13.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

class PriorityQueue<T: Comparable> {
    private var heap: BinaryHeap = BinaryHeap<T>(10)
    
    func size() -> Int {
        return heap.size
    }
    
    func isEmpty() -> Bool {
        return heap.isEmpty()
    }
    
    func clear() {
        heap.clear()
    }
    
    func enQueue(_ ele: T) {
        heap.add(ele)
    }
    
    func deQueue() -> T {
        return heap.remove()
    }
    
    func front() -> T {
        return heap.get()
    }
}

/*
let queue = PriorityQueue<Int>()
queue.enQueue(12)
queue.enQueue(13)
queue.enQueue(14)
queue.enQueue(15)
queue.enQueue(10)
queue.enQueue(9)
queue.enQueue(8)
queue.enQueue(20)
assert(queue.deQueue() == 20)
assert(queue.deQueue() == 15)
assert(queue.deQueue() == 14)
assert(queue.deQueue() == 13)
*/
