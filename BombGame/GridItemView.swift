//
//  GridItemView.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class GridItemView: UIView {
    private var isOpen = false
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        return label
    }()
    private let maskItem = UIView()
    
    let item: GridItem
    
    init(item: GridItem, frame: CGRect) {
        self.item = item
        super.init(frame: frame)
        isUserInteractionEnabled = true
        
        textLabel.frame = bounds
        if !item.type.isEmpty {
            textLabel.text = item.type.debugDescription
        }
        switch item.type {
        case .bomb:
            backgroundColor = UIColor(red:1,  green:0.514,  blue:0.584, alpha:1)
        case .number(let value):
            switch value {
            case 1...2:
                textLabel.textColor = UIColor(red:0.251,  green:0.733,  blue:0.882, alpha:1)
            case 3...4:
                textLabel.textColor = UIColor(red:0.984,  green:0.733,  blue:0.102, alpha:1)
            case 5...6:
                textLabel.textColor = UIColor(red:0,  green:0.518,  blue:0.706, alpha:1)
            default:
                break
            }
            backgroundColor = UIColor.white
        }
        addSubview(textLabel)
        
        maskItem.frame = bounds
        maskItem.backgroundColor = UIColor.lightGray
        addSubview(maskItem)
        
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1

    }
    
    func changeState(open: Bool) {
        maskItem.isHidden = open
        item.isOpen = open
    }
    
    func changeBoom() {
        backgroundColor = UIColor(red:0.996,  green:0.263,  blue:0.518, alpha:1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
