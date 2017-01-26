//
//  ViewController.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit


private let kContainerInset: CGFloat = 20
private let kContainerSize = UIScreen.main.bounds.height - kContainerInset * 2

class ViewController: UIViewController {
    
    fileprivate var size = Size.init(width: 10, height: 10)
    fileprivate var numOfBomb = 10
    fileprivate lazy var items: [[GridItem]] = {
        return GridItemBuilder.init(size: self.size, numOfBomb: self.numOfBomb)?.items ?? [[GridItem]]()
    }()
    fileprivate let container = GridContainerView(frame: CGRect(x: kContainerInset, y: kContainerInset, width: kContainerSize, height: kContainerSize))

    @IBOutlet weak var widthField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var bombField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.dataSource = self
        container.delegate = self
        container.reloadData()
        view.addSubview(container)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func playButtonDidClick(_ sender: Any) {
        let w = Int(widthField.text ?? "") ?? 10
        let h = Int(heightField.text ?? "") ?? 10
        let b = min(Int(bombField.text ?? "") ?? 1, w * h)
        size = Size.init(width: w, height: h)
        numOfBomb = b
        items = GridItemBuilder.init(size: size, numOfBomb: numOfBomb)?.items ?? [[GridItem]]()
        container.reloadData()
    }

}

extension ViewController {


}


extension ViewController: GridContainerDelegate, GridContainerDataSource {
    func didClickItem(_ container: GridContainerView, item: GridItemView) {
        item.changeState(open: true)
        if item.item.type.isEmpty {
            for p in item.item.point.arround {
                guard p.isEnable(size: size),
                    let itemView = container.itemViews[p],
                    itemView.item.type.isEmpty,
                    !itemView.item.isOpen else { continue }
                didClickItem(container, item: itemView)
            }
        }
        if item.item.type.isBomb {
            item.changeBoom()
            container.itemViews.values.forEach { $0.changeState(open: true) }
            let alert = UIAlertController.init(title: "You are lose", message: "Do you want to try again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "Again", style: UIAlertActionStyle.default, handler: { _ in
                container.reloadData()
            }))
            container.isUserInteractionEnabled = false
            present(alert, animated: true, completion: nil)
        }
    }
    
    func sizeOfContainer(_ container: GridContainerView) -> Size {
        let h = items.count
        let w = items.first?.count ?? 0
        return Size.init(width: w, height: h)
    }
    func didOpenItemForContainer(_ container: GridContainerView, point: Point) -> Bool {
        return items[point.y][point.x].isOpen
    }
    
    func itemForContainer(_ container: GridContainerView, point: Point) -> GridItem {
        return items[point.y][point.x]
    }
    
}
