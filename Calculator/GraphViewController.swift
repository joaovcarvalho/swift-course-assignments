//
//  GraphViewController.swift
//  Calculator
//
//  Created by Joao Carvalho on 23/10/2016.
//  Copyright © 2016 Joao Carvalho. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!{
        didSet{
            if let calc = calculate {
                graphView.setCalculator(cal: calc)
            }
            
            if let desc = descriptor{
                graphView.setDescriptor(desc: desc)
            }
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeScale(recognizer:))
            ))
            
            var tap = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.setOrigin(recognizer:)))
            tap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tap)
            
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.panOrigin(recognizer:))
            ))
        }
    }
    
    var calculate: ((Double) -> Double )?
    var descriptor: (() -> String)?
    
    public func setCalculateFunction(calculateFunction: @escaping (Double) -> Double){
        calculate = calculateFunction
    }
    
    public func setDescriptor(desc: @escaping () -> String){
        descriptor = desc
    }
}

