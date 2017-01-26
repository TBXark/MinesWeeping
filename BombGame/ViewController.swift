//
//  ViewController.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    fileprivate var size: Size
    fileprivate var numOfBomb: Int
    fileprivate var items: [[GridItem]]


    @IBOutlet weak var container: GridContainerView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var widthField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var bombField: UITextField!
    
    
    required init?(coder aDecoder: NSCoder) {
        size = Size(width: 10, height: 10)
        numOfBomb = 10
        items = GridItemBuilder(size: size, numOfBomb: numOfBomb)?.items ?? [[GridItem]]()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.dataSource = self
        container.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func playButtonDidClick(_ sender: Any) {
        reloadData()
    }
    
    
    fileprivate func reloadData() {
        let w = Int(widthField.text ?? "") ?? 10
        let h = Int(heightField.text ?? "") ?? 10
        let b = min(Int(bombField.text ?? "") ?? 1, w * h)
        let s = Size(width: w, height: h)
        let res = GridItemBuilder(size: s, numOfBomb: b)?.items
        guard let newItems = res, newItems.count > 0 else {
            let alert = UIAlertController(title: "Error", message: "The input number is wrong, please input again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "I know", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        size = s
        numOfBomb = b
        items = newItems
        stateLabel.text = "The current size is \(w) * \(h), Number of bombs is \(b)"
        container.reloadData()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

}

extension ViewController: GridContainerDelegate, GridContainerDataSource {
    func didClickItem(_ container: GridContainerView, item: GridItemView) {
        guard !item.item.isOpen else { return }
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
            let alert = UIAlertController(title: "You are lose", message: "Do you want to try again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Again", style: UIAlertActionStyle.default, handler: { _ in
                self.reloadData()
            }))
            container.isUserInteractionEnabled = false
            present(alert, animated: true, completion: nil)
        } else {
            let final = size.height * size.width - numOfBomb
            let current = items.reduce(0, { (c: Int, n: [GridItem]) -> Int in
                return c + n.numOfOpen
            })
            if current == final {
                let alert = UIAlertController(title: "You are Win", message: "Do you want to try again", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Again", style: UIAlertActionStyle.default, handler: { _ in
                    self.reloadData()
                }))
                container.isUserInteractionEnabled = false
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func sizeOfContainer(_ container: GridContainerView) -> Size {
        let h = items.count
        let w = items.first?.count ?? 0
        return Size(width: w, height: h)
    }
    
    func itemForContainer(_ container: GridContainerView, point: Point) -> GridItem {
        return items[point.y][point.x]
    }
    
}
