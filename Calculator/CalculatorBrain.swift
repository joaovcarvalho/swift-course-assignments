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
    
    private var variableNames: Dictionary<String, Double> = [:]
    
    public func setVariable(variableName:String, value:Double){
        variableNames[variableName] = value
        program = internalProgram
    }
    
    func setOperand(_ variableName:String){
        if let value = variableNames[variableName] {
            accumulator = value
        }else{
            accumulator = 0.0
        }
        
        changedOperand = false
        internalProgram.append(variableName as AnyObject)
        descriptionList.append(variableName as AnyObject)
        
    }
    
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
    
    func undo(){
        internalProgram.remove(at: internalProgram.index(before: internalProgram.endIndex))
        program = internalProgram
        print("Undo called")
        print(internalProgram)
    }
    
    func clear(){
        accumulator = 0.0
        pending = nil
        descriptionList = []
        internalProgram = []
        changedOperand = false
    }
    
    func clearVariables(){
        variableNames = [:]
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
        }else if let variable = variableNames[symbol]{
            internalProgram.append(symbol as AnyObject)
            accumulator = variable
            descriptionList.append(symbol as AnyObject)
            changedOperand = false
            
        }
    }
    
    func executePendingBinaryOperation(){
        if pending != nil{
            
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
