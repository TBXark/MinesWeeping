//
//  GridItemModel.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

enum GridType: CustomDebugStringConvertible {
    
    case bomb
    case number(value: Int)
    
    var isBomb: Bool {
        switch self {
        case .bomb: return true
        default: return false
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .bomb: return false
        case .number(let value): return value == 0
        }
    }
    
    func increase() -> GridType {
        switch self {
        case .bomb: return .bomb
        case .number(let value): return .number(value: value + 1)
        }
    }
    
    
    var debugDescription: String {
        switch self {
        case .bomb: return "💣"
        case .number(let value): return "\(value)"
        }
    }
}


struct Size {
    let width: Int
    let height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    
    var topLeft: Point {
        return Point.init(x: x - 1, y: y - 1)
    }
    var topRight: Point {
        return Point.init(x: x + 1, y: y - 1)
    }
    var bottomLeft: Point {
        return Point.init(x: x - 1, y: y + 1)
    }
    var bottomRight: Point {
        return Point.init(x: x + 1, y: y + 1)
    }
    var top: Point {
        return Point.init(x: x, y: y - 1)
    }
    var bottom: Point {
        return Point.init(x: x, y: y + 1)
    }
    var left: Point {
        return Point.init(x: x - 1, y: y)
    }
    var right: Point {
        return Point.init(x: x + 1, y: y)
    }
    
    var arround: [Point] {
        return [topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left]
    }
    
    
    static func radomd(size: Size) -> Point {
        let x = Int(arc4random()) % ( size.width + 1 )
        let y = Int(arc4random()) % ( size.height + 1 )
        return Point.init(x: x, y: y)
    }
    
    var hashValue: Int {
        return "\(x)|\(y)".hashValue
    }
    
    
    func isEnable(size: Size) -> Bool {
        guard x >= 0, y >= 0, x < size.width, y < size.height else { return false }
        return true
    }
}


func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}


class GridItem {
    let type: GridType
    let point: Point
    var isOpen: Bool = false
    
    init(type: GridType, point: Point) {
        self.type = type
        self.point = point
    }
}


struct GridItemBuilder {
    let items: [[GridItem]]
    
    init?(size: Size, numOfBomb: Int) {
        guard size.width > 0, size.height > 0, numOfBomb > 0, numOfBomb < size.width * size.height else { return nil }
        var total = [[GridType]].init(repeating: [GridType].init(repeating: GridType.number(value: 0), count: size.width), count: size.height)
        
        var bombSet = Set<Point>()
        while bombSet.count < numOfBomb {
            _ = bombSet.insert(Point.radomd(size: size))
        }
        
        for x in 0..<size.width {
            for y in 0..<size.height {
                let p = Point(x: x, y: y)
                if bombSet.contains(p) {
                    total[x][y] = GridType.bomb
                    for r in p.arround {
                        if r.isEnable(size: size) {
                            total[r.x][r.y] = total[r.x][r.y].increase()
                        }
                    }
                }
            }
        }
        items = total.enumerated().map({ (y: Int, element: [GridType]) -> [GridItem] in
            return element.enumerated().map({  (x: Int, type: GridType) -> GridItem in
                return GridItem.init(type: type, point: Point.init(x: x, y: y))
            })
        })
    }
}


