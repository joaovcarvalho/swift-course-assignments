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
    
    func setOperand(operand: Double) {
        accumulator = operand
        if description == ""{
            description = String(operand)
        }else if !isPartialResult(){
            description = String(operand)
            changedOperand = false
        }
    }
    
    func isPartialResult() -> Bool {
        return pending != nil
    }
    
    var operations: Dictionary<String,Operation> = [
        "∏" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "DEL": Operation.Constant(0.0),
        "cos": Operation.UnaryOperation(cos),
        "√"  : Operation.UnaryOperation(sqrt),
        "sin": Operation.UnaryOperation(sin),
        "ln" : Operation.UnaryOperation(log),
        "×"  : Operation.BinaryOperation({ $0 * $1 }),
        "÷"  : Operation.BinaryOperation({ $0 / $1 }),
        "+"  : Operation.BinaryOperation({ $0 + $1 }),
        "-"  : Operation.BinaryOperation({ $0 - $1 }),
        "ˆ"  : Operation.BinaryOperation(pow),
        "="  : Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    private struct PendingBinaryOperationInfo{
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
    }
    
    private var pending : PendingBinaryOperationInfo?
    
    private var description : String = ""
    
    internal func getDescriptionOfOperations() -> String {
        if(isPartialResult()){
            return description + "..."
        }else{
            return description + "="
        }
    }
    
    var changedOperand = false
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constant):
                accumulator = constant;
                description = description + symbol
                changedOperand = true
            case .UnaryOperation(let function):
                
                if isPartialResult(){
                    description = description + symbol + String(accumulator)
                }else{
                    description = symbol + description
                }
                
                accumulator = function(accumulator);
                changedOperand = true
            case .BinaryOperation(let function):
                
                executePendingBinaryOperation()
                
                description = description + symbol
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
        
        print(getDescriptionOfOperations())
        
    }
    
    func executePendingBinaryOperation(){
        if pending != nil{
            if !changedOperand{
                description = description + String(accumulator)
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
