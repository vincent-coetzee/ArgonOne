//
//  ArgonRegisterFile.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonRegisterFile
    {
    public private(set) static var R0:VMRegister = VMRegister(.R0)
    public private(set) static var BP:VMRegister = VMRegister(.BP)
    public private(set) static var SP:VMRegister = VMRegister(.SP)
    
    public private(set) var registerCount:Int
    public private(set) var registers:[VMRegister] = []
    public private(set) var reservedRegisters:[VMRegister] = []
    public private(set) var isFloatingPoint:Bool
    
    init(count:Int,floatingPoint:Bool)
        {
        self.registerCount = count
        isFloatingPoint = floatingPoint
        let first = isFloatingPoint ? Argon.kOffsetOfFirstFloatingPointRegisterForUse : Argon.kOffsetOfFirstRegisterForUse
        for index in 0..<Argon.kOffsetOfFirstRegisterForUse
            {
            reservedRegisters.append(VMRegister(rawValue: index))
            }
        for index in first..<first + count - Argon.kNumberOfReservedRegisters
            {
            registers.append(VMRegister(rawValue: index))
            }
        }
    
    public func allocateRegister(for value:ThreeAddress?,with: ThreeAddressCodeGenerator) throws -> VMRegister
        {
        if value != nil
            {
            let alreadyContains = registers.filter {$0.contents != nil && $0.contents!.isSame(as: value!)}
            if value!.locations.hasRegisterLocation && value!.locations.registerLocation.contains(value!) && alreadyContains.count > 0
                {
                let register = alreadyContains.first!
                print("Returning register \(register.register) which CONTAINS \(value)")
                register.contents?.locations.remove(register: register)
                register.contents = value
                let index = registers.index(of: register)!
                registers.remove(at:index)
                return(register)
                }
            }
        let empty = registers.filter {$0.isEmpty }
        if empty.count > 0
            {
            let register = empty.first!
            let index = registers.index(of: register)
            registers.remove(at: index!)
            print("Returning register \(register.register) which is EMPTY")
            return(register)
            }
        var register:VMRegister
        register = registers.first!
        registers.removeFirst()
        if register.contents != nil && !register.contents!.locations.isEmpty
            {
            print("Returning register \(register.register) with ALTERNATE LOCATION")
            register.contents?.locations.remove(register: register)
            register.contents = nil
            return(register)
            }
        else if value != nil && value!.locations.containsAddressOrStackLocation()
            {
            if value!.locations.hasAddressLocation
                {
                let address = value!.locations.addressLocation
                with.instructions.append(.STORE(register1:register,address:address))
                }
            else if value!.locations.hasStackLocation
                {
                let stackOffset = value!.locations.stackLocation
                with.instructions.append(.MOV(register1:register,register2: VMRegister(.BP),plus: stackOffset))
                }
            register.contents?.locations.removeAllRegisterLocations()
            register.contents = nil
            print("Returning register \(register.register) which was SPILLED")
            return(register)
            }
        else
            {
            let offset = with.nextOffsetInDataSegment()
            with.instructions.append(.STORE(register1:register,immediate:offset))
            register.contents!.locations.removeAllRegisterLocations()
            register.contents!.locations.append(address: ArgonWord(offset))
            register.contents = nil
            print("Returning register \(register.register) which was SPILLED")
            return(register)
            }
        }
    
    public func returnRegister(_ register:VMRegister)
        {
        if !registers.contains(register) && !reservedRegisters.contains(register)
            {
            registers.append(register)
            }
        }
    }
