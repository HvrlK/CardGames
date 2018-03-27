//
//  BoardView.swift
//  Set2
//
//  Created by Vitalii Havryliuk on 3/15/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var cardViews = [SetCardView]() {
        willSet { removeSubviews() }
        didSet { addSubviews(); layoutIfNeeded() }
    }
    
    private func removeSubviews() {
        for card in cardViews {
            card.removeFromSuperview()
        }
    }
    
    func addSubviews() {
        for card in cardViews {
            addSubview(card)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var grid = Grid(layout: .aspectRatio(Constants.cellAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                if cardViews.count > (row * grid.dimensions.columnCount + column) {
                    cardViews[row * grid.dimensions.columnCount + column].frame =
                        grid[row,column]!.insetBy(
                            dx: Constants.spacingDx, dy: Constants.spacingDy)
                }
            }
        }
    }
    
}

struct Constants {
    static let cellAspectRatio: CGFloat = 0.7
    static let spacingDx: CGFloat = 2.0
    static let spacingDy: CGFloat = 2.0
}
