//
//  GraphView.swift
//  Calculator
//
//  Created by Joao Carvalho on 23/10/2016.
//  Copyright © 2016 Joao Carvalho. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView
{
    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var originOffset = CGPoint(x:0,y:0) { didSet {
        setNeedsDisplay()
    } }
    
    var calculator: ((Double) -> Double)?
    
    func setCalculator(cal: @escaping (Double) -> Double){
        calculator = cal
    }
    
    var descriptor: (() -> String)?
    
    func setDescriptor(desc: @escaping () -> String){
        descriptor = desc
    }
    
    private var origin: CGPoint {
        return CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y)
    }
    
    public var pointsPerUnit: CGFloat {
        get{
            return CGFloat(50/scale)
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func panOrigin(recognizer: UIPanGestureRecognizer){
        switch recognizer.state {
        case .changed,.ended:
            let translation = recognizer.translation(in: self)
            originOffset = CGPoint(x: originOffset.x + translation.x,
                                   y: originOffset.y + translation.y)
            recognizer.setTranslation(CGPoint(x: 0,y: 0), in: self)
        default:
            break
        }
    }
    
    func setOrigin(recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .changed,.ended:
            let pos = recognizer.location(in: self)
            
            originOffset = CGPoint(x: pos.x - bounds.midX, y: pos.y - bounds.midY)
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        AxesDrawer(color: UIColor.red,
                   contentScaleFactor: self.contentScaleFactor)
            .drawAxesInRect(
                bounds: bounds,
                origin: origin,
                pointsPerUnit: pointsPerUnit)
        
        var p = alignedPoint(x: bounds.minX,y: bounds.midY,insideBounds: bounds)!
        UIColor.blue.set()
        let path = UIBezierPath()
        
        path.move(to: p)
        
        while let newPoint = alignedPoint(x: p.x + 1.0, y: p.y, insideBounds: bounds) {
            
            print(newPoint)
            var graphPoint = getGraphPoint(p: p)
            
            if let calc = calculator{
                graphPoint.y = CGFloat(calc(Double(graphPoint.x)))
            }
            
            print(graphPoint)
            
            let pixelPoint = getPixelPoint(p: graphPoint)
            print(pixelPoint)
            
            if let calculatedPoint = alignedPoint(x: pixelPoint.x, y: pixelPoint.y){
                path.addLine(to: calculatedPoint)
                path.move(to: calculatedPoint)
            }else{
                path.addLine(to: newPoint)
                path.move(to: newPoint)
            }
            
            p = newPoint
        }
        
        path.stroke()
        
        if let calc = calculator{
            calc(0.0)
        }
        
        if let desc = descriptor{
            let text: String = desc()
            let attributes = [
                NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSForegroundColorAttributeName : UIColor.black
            ]
            
            var textRect = CGRect(center: CGPoint(x: 20,y: 20),
                                  size: CGSize(width: CGFloat(200.0), height: CGFloat(200.0)))
            text.draw(in: textRect, withAttributes: attributes)
            print(text)
        }
    }
    
    private func getGraphPoint(p: CGPoint) -> CGPoint{
        let graph_x = (-origin.x+p.x)/pointsPerUnit
        let graph_y = (origin.y-p.y)/pointsPerUnit
        return CGPoint(x: graph_x,y: graph_y)
    }
    
    private func getPixelPoint(p: CGPoint) -> CGPoint{
        let pixel_x = origin.x+(p.x*pointsPerUnit)
        let pixel_y = origin.y-(p.y*pointsPerUnit)
        return CGPoint(x: pixel_x,y: pixel_y)
    }
    
    private func alignedPoint(x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(coordinate: x), y: align(coordinate:y))
        if let permissibleBounds = insideBounds {
            if (!permissibleBounds.contains(point)) {
                return nil
            }
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

