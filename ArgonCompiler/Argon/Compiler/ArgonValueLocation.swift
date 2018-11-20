//
//  ArgonStorageLocation.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum ArgonValueLocation
    {
    case stack(Int)
    case address(ArgonWord)
    case register(VMRegister)
    }

public class ArgonValueLocationList
    {
    public var locations:[ArgonValueLocation] = []
    public var track:Bool = false
    
    public var isEmpty:Bool
        {
        return(locations.count == 0)
        }
    
    public var hasRegisterLocation:Bool
        {
        for location in locations
            {
            if case ArgonValueLocation.register(_) = location
                {
                return(true)
                }
            }
        return(false)
        }
    
    public var hasAddressLocation:Bool
        {
        for location in locations
            {
            if case ArgonValueLocation.address(_) = location
                {
                return(true)
                }
            }
        return(false)
        }
    
    public var hasStackLocation:Bool
        {
        for location in locations
            {
            if case ArgonValueLocation.stack(_) = location
                {
                return(true)
                }
            }
        return(false)
        }
    
    public var registerLocation:VMRegister
        {
        for location in locations
            {
            if case let ArgonValueLocation.register(aRegister) = location
                {
                return(aRegister)
                }
            }
        fatalError()
        }
    
    public var addressLocation:ArgonWord
        {
        for location in locations
            {
            if case let ArgonValueLocation.address(address) = location
                {
                return(address)
                }
            }
        fatalError()
        }
    
    public var stackLocation:Int
        {
        for location in locations
            {
            if case let ArgonValueLocation.stack(offset) = location
                {
                return(offset)
                }
            }
        fatalError()
        }
    
    public func registers() -> [VMRegister]
        {
        var registers:[VMRegister] = []
        for location in locations
            {
            if case let ArgonValueLocation.register(register) = location
                {
                registers.append(register)
                }
            }
        return(registers)
        }
    
    public func removeAllRegisterLocationsThenAdd(register:VMRegister)
        {
        self.removeAllRegisterLocations()
        self.append(register: register)
        }
    
    public func removeAllRegisterLocations()
        {
        if track
            {
            print("all register locations removed")
            }
        locations.removeAll(where:
            {
            (location:ArgonValueLocation) -> Bool in
            if case ArgonValueLocation.register(_) = location
                {
                return(true)
                }
            return(false)
            })
        }
    
    public func doesNotContain(register:VMRegister) -> Bool
        {
        for location in locations
            {
            if case ArgonValueLocation.address(_) = location
                {
                return(true)
                }
            else if case ArgonValueLocation.stack(_) = location
                {
                return(true)
                }
            else if case let ArgonValueLocation.register(newRegister) = location
                {
                return(newRegister != register)
                }
            }
        return(false)
        }
    
    public func containsAddressOrStackLocation() -> Bool
        {
        for location in locations
            {
            if case ArgonValueLocation.address(_) = location
                {
                return(true)
                }
            else if case ArgonValueLocation.stack(_) = location
                {
                return(true)
                }
            }
        return(false)
        }
    
    public func append(_ location:ArgonValueLocation)
        {
        locations.append(location)
        }
    
    public func append(register:VMRegister)
        {
        self.append(.register(register))
        }
    
    public func append(address:ArgonWord)
        {
        self.append(.address(address))
        }
    
    public func append(stack:Int)
        {
        self.append(.stack(stack))
        }
    
    public func remove(register:VMRegister)
        {
        if track
            {
            print("removing register \(register.register)")
            }
        locations.removeAll
            {
            element in
            if case let ArgonValueLocation.register(aRegister) = element
                {
                if aRegister.register == register.register
                    {
                    return(true)
                    }
                }
            return(false)
            }
        }
    }
