//
//  GridContainerView.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

protocol GridContainerDelegate: class {
    func didClickItem(_ container: GridContainerView, item: GridItemView)
}

protocol GridContainerDataSource: class {
    func sizeOfContainer(_ container: GridContainerView) -> Size
    func didOpenItemForContainer(_ container: GridContainerView, point: Point) -> Bool
    func itemForContainer(_ container: GridContainerView, point: Point) -> GridItem
}


class GridContainerView: UIView {
    weak var delegate: GridContainerDelegate?
    weak var dataSource: GridContainerDataSource?
    
    private(set) var itemViews = [Point: GridItemView]()
    
    func reloadData() {
        guard let dataSource = dataSource else { return }
        isUserInteractionEnabled = true
        let s = min(bounds.width, bounds.height)
        let offsetX = abs(bounds.width - s)/2
        let offSetY = abs(bounds.height - s)/2
        let size = dataSource.sizeOfContainer(self)
        let itemSize = s/CGFloat(max(size.width, size.height))
        
        itemViews.removeAll()
       
        for x in 0..<size.width {
            for y in 0..<size.height {
                let p = Point.init(x: x, y: y)
                let rect = CGRect(x: offsetX + CGFloat(x) * itemSize, y: offSetY + CGFloat(y) * itemSize, width: itemSize, height: itemSize)
                let item = dataSource.itemForContainer(self, point: p)
                let itemView = GridItemView.init(item: item, frame: rect)
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(GridContainerView.didClickItem(_:)))
                itemView.addGestureRecognizer(tap)
                addSubview(itemView)
                itemViews[p] = itemView
            }
        }
    }
    
    
    @objc func didClickItem(_ tap: UITapGestureRecognizer) {
        guard  let item = tap.view as? GridItemView else {
            return
        }
        delegate?.didClickItem(self, item: item)
    }
}
