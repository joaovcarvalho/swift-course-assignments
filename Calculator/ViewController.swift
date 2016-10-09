//
//  ViewController.swift
//  Calculator
//
//  Created by Joao Carvalho on 20/09/2016.
//  Copyright © 2016 Joao Carvalho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    fileprivate var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        
        set {
            display.text = String(newValue)
        }
        
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue  = brain.result
            descriptionLabel.text = brain.getDescriptionOfOperations()
        }
    }
    
    
    fileprivate var floatingPointAdded = false
    @IBAction func clearEverything(_ sender: AnyObject) {
        brain.clear()
        displayValue = 0
        descriptionLabel.text = "..."
    }
    
    @IBAction func addDot(_ sender: UIButton) {
        if !floatingPointAdded && userIsInTheMiddleOfTyping{
            display.text = display.text! + "."
            floatingPointAdded = true
        }
    }
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(mathematicalSymbol)
        }
        
        displayValue = brain.result
        floatingPointAdded = false
        descriptionLabel.text = brain.getDescriptionOfOperations()
    }
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let currentTextInDisplay = display.text!
        if userIsInTheMiddleOfTyping {
            display.text = currentTextInDisplay + digit
        }else{
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    
}

