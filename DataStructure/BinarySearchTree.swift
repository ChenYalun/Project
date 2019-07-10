//
//  BinarySearchTree.swift
//  Le
//
//  Created by Chen,Yalun on 2019/7/10.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

import Foundation

class BinarySearchTree<T: Comparable> {
    fileprivate var nodeCount = 0 // 结点数量
    fileprivate var root: Node<T>? // 根节点
    
    // 二叉搜索树是否为空
    func isEmpty() -> Bool {
        return nodeCount == 0
    }
    
    // 清空
    func clear() {
        root = nil
        nodeCount = 0
    }
    
    // 查找结点
    fileprivate func findNode(_ ele: T) -> Node<T>? {
        var p = root
        while p != nil {
            if ele == p!.ele {
                // 元素相等, 直接替换
                return p
            } else if ele < p!.ele {
                // 位于左子树
                p = p!.left
            } else {
                // 位于右子树
                p = p!.right
            }
        }
        return p
    }
    
    // 添加结点
    func addNode(_ ele: T) {
        // 添加的是根节点
        if root == nil {
            root = Node(ele, nil)
            nodeCount += 1
            return
        }
            // 添加的不是根结点
        else {
            var p = root
            var parent = root
            while p != nil {
                parent = p
                if ele == p!.ele {
                    // 元素相等, 直接替换
                    p?.ele = ele
                    return
                } else if ele < p!.ele {
                    // 位于左子树
                    p = p!.left
                } else {
                    // 位于右子树
                    p = p!.right
                }
            }
            
            // 得到parent结点
            if ele > parent!.ele {
                parent?.right = Node(ele, parent)
            } else {
                parent?.left = Node(ele, parent)
            }
            // 总结点数量加1
            nodeCount += 1
        }
    }
    
    // 移除结点
    fileprivate func remove(_ ele: T) {
        var node: Node<T>? = findNode(ele)
        if node == nil {
            // 没有找到需要删除的结点
            return
        }
        
        // 结点数量减1
        nodeCount -= 1
        
        // 度为2的结点
        if node!.hasTwoChildren() {
            // 找它的后继结点
            let p = successor(node)
            // 用后继结点内容替换待删除结点内容
            node!.ele = p!.ele
            // 需要删的结点就是node结点了
            node = p
        }
        
        // node是叶子结点而且也是根结点
        if node?.parent == nil {
            root = nil
            return
        }
        
        // 需要替换的结点
        let replace = node?.left == nil ? node?.right : node?.left
        if replace == nil {
            // node没有左子树也没有右子树, 说明node是叶子结点
            if node?.parent?.left == node {
                // node是父结点的左结点
                node?.parent?.left = nil
            } else {
                // node是父结点的右结点
                node?.parent?.right = nil
            }
        } else {
            if node?.parent == nil {
                // 是根结点
                root = replace
            } else if node?.parent?.left == node {
                // 是左结点
                node?.parent?.left = replace
            } else {
                // 是右结点
                node?.parent?.right = replace
            }
        }
    }
    
    // 前序遍历(一般是根左右)
    fileprivate func preorderTraversal() {
        print("---------以下是递归方式结果---------")
        preorderTraversal(root)
        print("---------以下是非递归方式结果---------")
        if root == nil {
            return
        }
        var results = [T]()
        let stack = Stack<Node<T>>()
        var p = root
        while p != nil || stack.size() != 0 {
            while p != nil {
                // 先访问 根
                results.append(p!.ele)
                stack.push(p!)
                // 再访问 左 (持续遍历左子树)
                p = p?.left
            }
            p = stack.pop()
            // 最后访问 右
            p = p?.right
        }
        print(results)
    }
    
    fileprivate func preorderTraversal(_ node: Node<T>?) {
        if node == nil {
            return
        }
        print(node!.ele)
        preorderTraversal(node!.left)
        preorderTraversal(node!.right)
    }
    
    // 中序遍历(一般是左根右)
    fileprivate func inorderTraversal() {
        print("---------以下是递归方式结果---------")
        inorderTraversal(root)
        print("---------以下是非递归方式结果---------")
        if root == nil {
            return
        }
        var results = [T]()
        let stack = Stack<Node<T>>()
        var p = root
        while p != nil || stack.size() != 0 {
            while p != nil {
                // 持续访问左子树
                stack.push(p!)
                p = p?.left
            }
            // 弹出栈顶元素
            p = stack.pop()
            // 先访问左子树
            results.append(p!.ele)
            p = p?.right
        }
        print(results)
    }
    
    fileprivate func inorderTraversal(_ node: Node<T>?) {
        if node == nil {
            return
        }
        inorderTraversal(node!.left)
        print(node!.ele)
        inorderTraversal(node!.right)
    }
    
    // 后序遍历(一般是左右根)
    fileprivate func postorderTraversal() {
        print("---------以下是递归方式结果---------")
        postorderTraversal(root)
        print("---------以下是非递归方式结果---------")
        var results = [T]()
        let stack = Stack<Node<T>>()
        var p = root
        var last: Node<T>? = nil
        while p != nil || stack.size() != 0 {
            while p != nil {
                // 持续访问左子树
                stack.push(p!)
                p = p?.left
            }
            p = stack.top()
            if p?.right == nil || p?.right == last {
                // 没有右子树或者访问过右子树
                results.append(p!.ele)
                _ = stack.pop()
                last = p
                p = nil
            } else {
                p = p?.right
            }
        }
        print(results)
    }
    
    fileprivate func postorderTraversal(_ node: Node<T>?) {
        if node == nil {
            return
        }
        postorderTraversal(node!.left)
        postorderTraversal(node!.right)
        print(node!.ele)
    }
    
    // 层序遍历--使用队列实现
    fileprivate func levelOrderTranversal() {
        let queue = Queue<Node<T>>()
        if root == nil {
            return
        }
        var results = [T]()
        queue.enQueue(root!)
        while queue.size() != 0 {
            let r = queue.deQueue()
            results.append(r.ele)
            if r.left != nil {
                queue.enQueue(r.left!)
            }
            if r.right != nil {
                queue.enQueue(r.right!)
            }
        }
        print(results)
    }
    
    // 是否是一颗完全二叉树
    fileprivate func isComplete() -> Bool {
        if root == nil {
            // 树为空
            return false
        }
        var isAllLeaf = false
        let queue = Queue<Node<T>>()
        queue.enQueue(root!)
        while queue.size() != 0 {
            let r = queue.deQueue()
            if isAllLeaf && !r.isLeaf() {
                return false
            }
            
            if r.left != nil {
                queue.enQueue(r.left!)
            } else if r.left == nil && r.right != nil {
                // 左子树为空而右子树不为空, 不是完全二叉树
                return false
            }
            
            if r.right != nil {
                queue.enQueue(r.right!)
            } else {
                // 左不为空右为空  或者 左右都为空, 要求之后的必须都是叶子结点
                isAllLeaf = true
            }
        }
        return true
    }
    
    
    /*
     6
     /    \
     3      7
     /  \     \
     2    4     10
     \     /
     5   9
     */
    // 查找前驱结点
    fileprivate func precursor(_ node: Node<T>?) -> Node<T>? {
        // 1. 空结点, 其前驱为空
        if node == nil {
            return nil
        }
        
        // 2. 前驱结点在左结点的右子树上, 比如找6的前驱
        var p = node!.left
        if p != nil {
            while p!.right != nil {
                p = p!.right
            }
            return p
        }
        
        // 3. 前驱结点在父节点\祖父结点上, 比如找9的前驱
        p = node
        while p!.parent != nil && p == p!.parent?.left {
            p = p!.parent
        }
        return p!.parent
    }
    
    // 查找后继结点
    fileprivate func successor(_ node: Node<T>?) -> Node<T>? {
        // 1. 空结点, 其后继为空
        if node == nil {
            return nil
        }
        
        // 2. 后继结点在右结点的左子树上, 比如找7的后继
        var p = node!.right
        if p != nil {
            while p!.left != nil {
                p = p!.left
            }
            return p
        }
        
        // 3. 后继结点在父节点\祖父结点上, 比如找5的后继
        p = node
        while p!.parent != nil && p == p!.parent?.right {
            p = p!.parent
        }
        return p!.parent
    }
    
    // 树的高度--迭代写法
    fileprivate func height() -> Int {
        // 层序遍历法
        let queue = Queue<Node<T>>()
        if root == nil {
            return 0
        }
        var level = 1
        var height = 0
        queue.enQueue(root!)
        while queue.size() != 0 {
            let r = queue.deQueue()
            level -= 1
            if r.left != nil {
                queue.enQueue(r.left!)
            }
            if r.right != nil {
                queue.enQueue(r.right!)
            }
            if level == 0 {
                // 这一层遍历结束
                level = queue.size()
                height += 1
            }
        }
        return height
        //return height(root)
    }
    
    // 树的高度--递归写法
    fileprivate func height(_ node: Node<T>?) -> Int {
        if node == nil {
            return 0
        }
        return 1 + max(height(node!.left), height(node!.right))
    }
    
    // 结点类
    class Node<T: Equatable>: Equatable {
        var ele: T
        var left: Node<T>?
        var right: Node<T>?
        var parent: Node<T>?
        init(_ ele: T, _ parent: Node?) {
            self.ele = ele
            self.parent = parent
        }
        
        // 叶子结点, 左右结点均为空
        func isLeaf() -> Bool {
            return left == nil && right == nil
        }
        
        // 有两个结点
        func hasTwoChildren() -> Bool {
            return left != nil && right != nil
        }
        
        // 是左子结点
        func isLeftChild() -> Bool {
            // 比较指针是否一致
            return parent != nil && parent?.left === self
        }
        
        // 是右子结点
        func isRightChild() -> Bool {
            // 比较指针是否一致
            return parent != nil && parent?.right === self
        }
        
        // 对等比较
        static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
            return lhs.ele == rhs.ele
        }
    }
}

/*
var bst = BinarySearchTree<Int>()
let list = [75, 62, 86, 24, 2, 89, 100, 9, 28, 31, 19, 78, 90, 48, 57]
for i in list {
    bst.addNode(i)
}
var a = bst.findNode(9)
//bst.preorderTraversal()
//print("------------------")
//bst.inorderTraversal()
//print("------------------")
//bst.postorderTraversal()
//print("------------------")
bst.levelOrderTranversal()
bst.remove(75)
bst.levelOrderTranversal()
//print(bst.isComplete())
//print(bst.height())
*/
