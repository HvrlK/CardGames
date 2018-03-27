//
//  SetCardView.swift
//  Set2
//
//  Created by Vitalii Havryliuk on 3/1/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    //MARK: properties
    
    var numberOfSymbols = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var formOfSymbol = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var shadingOfSymbol = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var colorOfSymbol = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isFaceUp = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    //MARK: public methods
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isFaceUp {
            drawFaceUpBackground()
            drawShapes()
        } else {
            drawFaceDownBackground()
        }
        
    }
    
    func drawShapes() {
        let grid = getGrid()
        
        for cellIndex in 0..<numberOfSymbols {
            setShapeColor()
            
            if let cellFrame = grid[cellIndex] {
                let shapePath = getShape(for: cellIndex, within: cellFrame)!
                
                switch shadingOfSymbol {
                case 1: shapePath.stroke()
                case 2: shapePath.fill()
                case 3: drawStripes(in: shapePath, within: cellFrame)
                default:
                    print("Error with shading of symbol")
                    return
                }
            }
        }
    }
    
    // MARK: private methods
    
    private func drawFaceUpBackground() {
        guard let graphicsContext = UIGraphicsGetCurrentContext() else {
            print("unable to get graphics context in drawFaceUpBackground()")
            return
        }
        graphicsContext.fill(bounds)
        let roundedRect = UIBezierPath(rect: bounds)
        UIColor.white.setFill()
        roundedRect.fill()
    }
    
    private func drawFaceDownBackground() {
        guard let graphicsContext = UIGraphicsGetCurrentContext() else {
            print("unable to get graphics context in drawFaceDownBackground()")
            return
        }
        graphicsContext.fill(bounds)
        let roundedRect = UIBezierPath(rect: bounds)
        #colorLiteral(red: 0.4622185826, green: 0.8411617279, blue: 1, alpha: 1).setFill()
        roundedRect.fill()
    }
    
    private func setShapeColor() {
        Color.colors[colorOfSymbol].setStroke()
        Color.colors[colorOfSymbol].setFill()
    }
    
    private func getShape(for cellNumber: Int, within bounds: CGRect) -> UIBezierPath? {
        switch formOfSymbol {
        case 1: return getDiamondPath(for: cellNumber, within: bounds)
        case 2: return getOvalPath(for: cellNumber, within: bounds)
        case 3: return getSquigglePath(for: cellNumber, within: bounds)
        default: return nil
        }
    }
    
    private func getGrid() -> Grid {
        var grid = Grid(layout: .dimensions(rowCount: 1, columnCount: 1))
        switch numberOfSymbols {
        case 1:
            grid = Grid(layout: .dimensions(rowCount: 1, columnCount: 1), frame: CGRect(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height / 3 , width: bounds.size.width, height: bounds.height / 3))
        case 2:
            grid = Grid(layout: .dimensions(rowCount: 2, columnCount: 1), frame: CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height / 6), width: bounds.size.width, height: (2 * bounds.height / 3)))
        case 3:
            grid = Grid(layout: .dimensions(rowCount: 3, columnCount: 1), frame: bounds)
        default:
            print("Error with number of symbols")
        }
        return grid
    }
    
    private func getDiamondPath(for cellNumber: Int, within bounds: CGRect) -> UIBezierPath {
        let diamondPath = UIBezierPath()
        
        diamondPath.move(to: CGPoint(x: bounds.midX, y: bounds.minY + gridInset))
        diamondPath.addLine(to: CGPoint(x: bounds.maxX - gridInset, y: bounds.midY))
        diamondPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY - gridInset))
        diamondPath.addLine(to: CGPoint(x: bounds.minX + gridInset, y: bounds.midY))
        diamondPath.close()
        
        return diamondPath
    }
    
    private func getOvalPath(for cellNumber: Int, within bounds: CGRect) -> UIBezierPath {
        let ovalPath = UIBezierPath()
        
        ovalPath.move(to: CGPoint(x: bounds.minX + 5 * gridInset, y: bounds.minY + gridInset))
        ovalPath.addLine(to: CGPoint(x: bounds.maxX - 5 * gridInset, y: bounds.minY + gridInset))
        ovalPath.addCurve(to: CGPoint(x: bounds.maxX - 5 * gridInset, y: bounds.maxY - gridInset),
                          controlPoint1: CGPoint(x: bounds.maxX - gridInset, y: bounds.midY - 3 * gridInset),
                          controlPoint2: CGPoint(x: bounds.maxX - gridInset, y: bounds.midY + 3 * gridInset))
        ovalPath.addLine(to: CGPoint(x: bounds.minX + 5 * gridInset, y: bounds.maxY - gridInset))
        ovalPath.addCurve(to: CGPoint(x: bounds.minX + 5 * gridInset, y: bounds.minY + gridInset),
                          controlPoint1: CGPoint(x: bounds.minX + gridInset, y: bounds.midY + 3 * gridInset),
                          controlPoint2: CGPoint(x: bounds.minX + gridInset, y: bounds.midY - 3 * gridInset))
        ovalPath.close()
        
        return ovalPath
    }
    
    private func getSquigglePath(for cellNumber: Int, within bounds: CGRect) -> UIBezierPath {
        let squigglePath = UIBezierPath()
        
        squigglePath.move(to: CGPoint(x: bounds.minX + gridInset * 3, y: bounds.minY + gridInset * 2))
        squigglePath.addCurve(to: CGPoint(x: bounds.maxX - gridInset * 3, y: bounds.minY + gridInset * 2),
                              controlPoint1: CGPoint(x: bounds.size.width / 3 + gridInset * 2, y: bounds.minY - gridInset),
                              controlPoint2: CGPoint(x: 2 * bounds.size.width / 3 - gridInset * 2, y: bounds.minY + gridInset * 5))
        squigglePath.addCurve(to: CGPoint(x: bounds.maxX - gridInset * 3, y: bounds.maxY - gridInset * 2),
                              controlPoint1: CGPoint(x: bounds.maxX - gridInset , y: bounds.midY - gridInset * 2),
                              controlPoint2: CGPoint(x: bounds.maxX - gridInset , y: bounds.midY + gridInset * 2))
        squigglePath.addCurve(to: CGPoint(x: bounds.minX + gridInset * 3, y: bounds.maxY - gridInset * 2),
                              controlPoint1: CGPoint(x: 2 * bounds.size.width / 3 - gridInset * 2, y: bounds.maxY + gridInset),
                              controlPoint2: CGPoint(x: bounds.size.width / 3 + gridInset * 2, y: bounds.maxY - gridInset * 5))
        squigglePath.addCurve(to: CGPoint(x: bounds.minX + gridInset * 3, y: bounds.minY + gridInset * 2),
                                          controlPoint1: CGPoint(x: bounds.minX + gridInset , y: bounds.midY + gridInset * 2),
                                          controlPoint2: CGPoint(x: bounds.minX + gridInset , y: bounds.midY - gridInset * 2))
        squigglePath.close()
        
        return squigglePath
    }
    
    private func drawStripes(in shapePath: UIBezierPath, within bounds: CGRect) {
        let yCoord = bounds.maxY
        let numberOfStripes = Int(bounds.width / SizeRatio.stripeInterval)
        
        UIGraphicsGetCurrentContext()?.saveGState()
        shapePath.addClip()
        
        for x in 0..<numberOfStripes {
            let xCoord = CGFloat(x)
            
            shapePath.move(to: CGPoint(x: xCoord * SizeRatio.stripeInterval, y: 0))
            shapePath.addLine(to: CGPoint(x: xCoord * SizeRatio.stripeInterval, y: yCoord))
        }
        
        shapePath.stroke()
        UIGraphicsGetCurrentContext()?.restoreGState()
    }
    
}

// extension for color literals
extension SetCardView {
    private struct Color {
        static let colors = [#colorLiteral(red: 0.8431758177, green: 0.8713032978, blue: 0.9073207487, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1), #colorLiteral(red: 0.1554745199, green: 0.612707145, blue: 0.7078045685, alpha: 1)]
    }
}

// extension for card size calculations
extension SetCardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.08
        static let stripeInterval: CGFloat = 5
    }
    
    private var gridInset: CGFloat {
        return bounds.size.height * 0.03
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
}



