//
//  ViewController.swift
//  Calculator
//
//  Created by Joao Carvalho on 20/09/2016.
//  Copyright © 2016 Joao Carvalho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        
        set {
            display.text = String(newValue)
        }
        
    }
    
    private var floatingPointAdded = false
    @IBAction func clearEverything(sender: AnyObject) {
        brain = CalculatorBrain()
        displayValue = 0
        descriptionLabel.text = "..."
    }
    
    @IBAction func addDot(sender: UIButton) {
        if !floatingPointAdded && userIsInTheMiddleOfTyping{
            display.text = display.text! + "."
            floatingPointAdded = true
        }
    }
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
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
    
    @IBAction private func touchDigit(sender: UIButton) {
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

