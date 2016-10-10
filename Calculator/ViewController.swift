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
    
    private func updateDisplay(){
        displayValue = brain.result
        descriptionLabel.text = brain.getDescriptionOfOperations()
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func setVariable() {
        brain.setVariable(variableName: "M", value: displayValue)
        updateDisplay()
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func setVariableOperand() {
        brain.setOperand("M")
    }
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            updateDisplay()
        }
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTyping {
            var digits: String = display.text!
            digits.remove(at: digits.index(before: digits.endIndex))
            display.text = digits
            if(display.text!.characters.count < 1){
                display.text = String(0.0)
            }
        }else{
            brain.undo()
            updateDisplay()
        }
    }
    
    fileprivate var floatingPointAdded = false
    @IBAction func clearEverything(_ sender: AnyObject) {
        brain.clear()
        brain.clearVariables()
        floatingPointAdded = false
        userIsInTheMiddleOfTyping = false
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
        
        floatingPointAdded = false
        updateDisplay()
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

