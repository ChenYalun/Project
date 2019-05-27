//
//  FlowCollectionView.swift
//  Framework
//
//  Created by Chen,Yalun on 2019/4/23.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

import UIKit

// 数据源
protocol FlowCollectionViewLayoutDataSource : class {
    func numberOfColumns(_ layout: FlowCollectionViewLayout) -> Int
    func heightOfItem(_ layout: FlowCollectionViewLayout, _ index: Int) -> CGFloat
}

// 自定义流水布局
class FlowCollectionViewLayout : UICollectionViewFlowLayout {
    // 代理
    weak var dataSource : FlowCollectionViewLayoutDataSource?
    // 列数
    fileprivate lazy var columns = {
        return self.dataSource?.numberOfColumns(self) ?? 2
    }()
    // 属性数组
    fileprivate lazy var attributesList = [UICollectionViewLayoutAttributes]()
    // 当前高度列表
    fileprivate lazy var heightList: [CGFloat] = Array(repeating: self.sectionInset.top, count: self.columns)
}

extension FlowCollectionViewLayout {
    // 1. 初始化
    override func prepare() {
        super.prepare()
        // 2. item数量
        let count = collectionView!.numberOfItems(inSection: 0)
        // 3. 宽度
        let width = (collectionView!.frame.width - sectionInset.left - sectionInset.right - CGFloat(columns - 1) * minimumInteritemSpacing) / CGFloat(columns)
        // 4. 遍历
        for i in attributesList.count..<count {
            // 1. 创建indexPath
            let indexPath = IndexPath(item: i, section: 0)
            // 2. 创建attributes
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            // 3. 高度
            guard let height = dataSource?.heightOfItem(self, indexPath.row) else {
                fatalError("未实现代理方法 heightOfItem")
            }
            let minHeight: CGFloat = heightList.min()!
            let minIndex: Int = heightList.index(of: minHeight)!
            // 4. 坐标
            let x = sectionInset.left + (width + minimumInteritemSpacing) * CGFloat(minIndex)
            let y = minHeight
            attributes.frame = CGRect(x: x, y: y, width: width, height: height)
            // 5. 添加attributes
            attributesList.append(attributes)
            // 6. 更新height
            heightList[minIndex] = y + height + minimumInteritemSpacing
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: heightList.max()! - sectionInset.top + sectionInset.bottom)
    }
}

// 使用示例
class FlowCollectionViewController : UIViewController {
    let cellIdentifier = "cellIdentifier"
    fileprivate lazy var flowCollectionView: UICollectionView = {
        let flowLayout = FlowCollectionViewLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.dataSource = self
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: 300, height: 400), collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(flowCollectionView)
        flowCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        flowCollectionView.reloadData()
    }
}

extension FlowCollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
}

extension FlowCollectionViewController : FlowCollectionViewLayoutDataSource {
    func heightOfItem(_ layout: FlowCollectionViewLayout, _ index: Int) -> CGFloat {
        return CGFloat(arc4random_uniform(150) + 100)
    }
    func numberOfColumns(_ layout: FlowCollectionViewLayout) -> Int {
        return 3
    }
}
