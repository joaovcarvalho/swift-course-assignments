//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Joao Carvalho on 27/09/2016.
//  Copyright © 2016 Joao Carvalho. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    
    private var internalProgram = [AnyObject]()
    
    func setOperand(_ operand: Double) {
        accumulator = operand
    
        if !isPartialResult(){
            descriptionList = []
        }
        
        internalProgram.append(operand as AnyObject)
        descriptionList.append(operand as AnyObject)
    }
    
    func isPartialResult() -> Bool {
        return pending != nil
    }
    
    var operations: Dictionary<String,Operation> = [
        "∏" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "DEL": Operation.constant(0.0),
        "cos": Operation.unaryOperation(cos),
        "√"  : Operation.unaryOperation(sqrt),
        "sin": Operation.unaryOperation(sin),
        "ln" : Operation.unaryOperation(log),
        "×"  : Operation.binaryOperation({ $0 * $1 }),
        "÷"  : Operation.binaryOperation({ $0 / $1 }),
        "+"  : Operation.binaryOperation({ $0 + $1 }),
        "-"  : Operation.binaryOperation({ $0 - $1 }),
        "ˆ"  : Operation.binaryOperation(pow),
        "="  : Operation.equals
    ]
    
    enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
    }
    
    private struct PendingBinaryOperationInfo{
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
    }
    
    private var pending : PendingBinaryOperationInfo?
    
    typealias PropertyList = [AnyObject]
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    }else if let operation = op as? String{
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear(){
        accumulator = 0.0
        pending = nil
        descriptionList = []
    }

    private var descriptionList : PropertyList = []
    
    internal func getDescriptionOfOperations() -> String {
        var description = ""
        for action in descriptionList{
            description = description + String(describing: action)
        }
        
        if(isPartialResult()){
            return description + "..."
        }else{
            return description + "="
        }
    }
    
    var changedOperand = false
    
    func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            
            internalProgram.append(symbol as AnyObject)
            
            switch operation {
            case .constant(let constant):
                accumulator = constant;
                descriptionList.append(symbol as AnyObject)
                changedOperand = true
            case .unaryOperation(let function):
                
                if isPartialResult(){
                    descriptionList.insert(symbol as AnyObject, at: descriptionList.count - 1)
                }else{
                    descriptionList.insert(symbol as AnyObject, at: 0)
                    descriptionList.insert("(" as AnyObject, at: 1)
                    descriptionList.append(")" as AnyObject)
                }
                
                accumulator = function(accumulator);
                changedOperand = true
            case .binaryOperation(let function):
                
                executePendingBinaryOperation()
                
                descriptionList.append(symbol as AnyObject)
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    func executePendingBinaryOperation(){
        if pending != nil{
            if isPartialResult() && changedOperand{
                descriptionList.append(accumulator as AnyObject)
            }
            
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            changedOperand = false
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
