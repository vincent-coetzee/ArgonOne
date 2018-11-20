//
//  ArgonStackFrame.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/08.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonStackFrame:Equatable
    {
    private static var framesStack:[ArgonStackFrame?] = []
    private static var currentFrame:ArgonStackFrame? = nil
    private static var nextCount = 1
    
    public var isThreadFrame:Bool
        {
        return(false)
        }
    
    private static var frames:[Int:ArgonStackFrame] = [:]
    
    public static func stackFrame(at:Int) -> ArgonStackFrame?
        {
        return(frames[at])
        }
    
    public static func ==(lhs:ArgonStackFrame,rhs:ArgonStackFrame) -> Bool
        {
        return(lhs.number == rhs.number)
        }
        
    public static func current() -> ArgonStackFrame?
        {
        return(currentFrame)
        }
    
    @discardableResult
    public static func push(scope:ArgonParseScope) -> ArgonStackFrame
        {
        let newFrame = ArgonStackFrame(previous:currentFrame)
        newFrame.number = nextCount
        ArgonStackFrame.frames[newFrame.number] = newFrame
        nextCount += 1
        newFrame.scope = scope
        framesStack.append(currentFrame)
        currentFrame = newFrame
        return(newFrame)
        }
        
    @discardableResult
    public static func pop() ->ArgonStackFrame?
        {
        currentFrame = framesStack.removeLast()
        return(currentFrame) 
        }
    
    public private(set) var previous:ArgonStackFrame?
    public private(set) var scope:ArgonParseScope?
    public private(set) var variables:[ArgonName:ArgonVariableNode] = [:]
    public private(set) var parameters:[ArgonName:ArgonParameterNode] = [:]
    public private(set) var number:Int = 0
    public var name:String = ""
    
    public var sizeInBytes:Int
        {
        return(variables.values.filter{$0 is ArgonLocalVariableNode}.count * 8)
        }
    
    init(previous:ArgonStackFrame?)
        {
        self.previous = previous
        }
        
    public func add(variable:ArgonVariableNode)
        {
        variables[variable.name] = variable
        scope?.add(variable: variable)
        variable.enclosingStackFrame = self
        }
    
    public func add(parameter:ArgonParameterNode)
        {
        parameters[parameter.name] = parameter
        parameter.enclosingStackFrame = self
        }
    }
