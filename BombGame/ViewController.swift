//
//  ViewController.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    fileprivate var size = Size.init(width: 10, height: 10)
    fileprivate var numOfBomb = 10
    fileprivate lazy var items: [[GridItem]] = {
        return GridItemBuilder.init(size: self.size, numOfBomb: self.numOfBomb)?.items ?? [[GridItem]]()
    }()


    @IBOutlet weak var container: GridContainerView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var widthField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var bombField: UITextField!
    
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
        let w = Int(widthField.text ?? "") ?? 10
        let h = Int(heightField.text ?? "") ?? 10
        let b = min(Int(bombField.text ?? "") ?? 1, w * h)
        size = Size.init(width: w, height: h)
        numOfBomb = b
        items = GridItemBuilder.init(size: size, numOfBomb: numOfBomb)?.items ?? [[GridItem]]()
        stateLabel.text = "The current size is \(w) * \(h), Number of bombs is \(b)"
        container.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

}

extension ViewController {


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
            let alert = UIAlertController.init(title: "You are lose", message: "Do you want to try again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "Again", style: UIAlertActionStyle.default, handler: { _ in
                container.reloadData()
            }))
            container.isUserInteractionEnabled = false
            present(alert, animated: true, completion: nil)
        } else {
            let final = size.height * size.width - numOfBomb
            let current = items.reduce(0, { (c: Int, n: [GridItem]) -> Int in
                return c + n.numOfOpen
            })
            if current == final {
                let alert = UIAlertController.init(title: "You are Win", message: "Do you want to try again", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: "Again", style: UIAlertActionStyle.default, handler: { _ in
                    container.reloadData()
                }))
                container.isUserInteractionEnabled = false
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func sizeOfContainer(_ container: GridContainerView) -> Size {
        let h = items.count
        let w = items.first?.count ?? 0
        return Size.init(width: w, height: h)
    }
    
    func itemForContainer(_ container: GridContainerView, point: Point) -> GridItem {
        return items[point.y][point.x]
    }
    
}
