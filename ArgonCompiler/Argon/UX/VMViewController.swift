//
//  VMViewController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/20.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class VMViewController: NSViewController
    {
    private enum DisplayFormat
        {
        case binary
        case decimal
        case hexadecimal
        }
    
    @IBOutlet var BPField:NSTextField!
    @IBOutlet var SPField:NSTextField!
    @IBOutlet var IPField:NSTextField!
    
    @IBOutlet var GPR0Field:NSTextField!
    @IBOutlet var GPR1Field:NSTextField!
    @IBOutlet var GPR2Field:NSTextField!
    @IBOutlet var GPR3Field:NSTextField!
    @IBOutlet var GPR4Field:NSTextField!
    @IBOutlet var GPR5Field:NSTextField!
    @IBOutlet var GPR6Field:NSTextField!
    @IBOutlet var GPR7Field:NSTextField!
    @IBOutlet var GPR8Field:NSTextField!
    @IBOutlet var GPR9Field:NSTextField!
    @IBOutlet var GPR10Field:NSTextField!
    @IBOutlet var GPR11Field:NSTextField!
    @IBOutlet var GPR12Field:NSTextField!
    @IBOutlet var GPR13Field:NSTextField!
    @IBOutlet var GPR14Field:NSTextField!
    @IBOutlet var GPR15Field:NSTextField!
    
    @IBOutlet var FPR0Field:NSTextField!
    @IBOutlet var FPR1Field:NSTextField!
    @IBOutlet var FPR2Field:NSTextField!
    @IBOutlet var FPR3Field:NSTextField!
    @IBOutlet var FPR4Field:NSTextField!
    @IBOutlet var FPR5Field:NSTextField!
    @IBOutlet var FPR6Field:NSTextField!
    @IBOutlet var FPR7Field:NSTextField!
    
    @IBOutlet var zeroField:NSTextField!
    @IBOutlet var ltField:NSTextField!
    @IBOutlet var lteField:NSTextField!
    
    @IBOutlet var instructionListView:ListView!
    @IBOutlet var stackListView:ListView!
    
    public private(set) var vm:VirtualMachine!
    private var currentDisplayFormat:DisplayFormat = .decimal
    private var currentDisplayLength:Int = 64
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        testBitSets()
        initInstructions()
        }
    
    private func testBitSets()
        {
        let set = ArgonBitSet(count: 64)
        set.setBit(at: 4)
        var bit = set.bit(at: 4)
        print(bit)
        set.setBit(at: 17)
        set.setBit(at: 32)
        bit = set.bit(at: 32)
        bit = set.bit(at: 29)
        set.setBit(pattern: 7, at: 40)
        let word = set.words[0]
        print(word)
        let pattern = set.bitPattern(at: 40...42)
        let count = set.numberOfSetBits(in: pattern)
        print(count)
        }
    
    private func initInstructions()
        {
        }
    
    private func formattedField(_ field:Int) -> String
        {
        switch(currentDisplayFormat)
            {
        case .decimal:
            return("\(field)")
        case .hexadecimal:
            return(Argon.hexString(of: UInt(bitPattern: Int(field)),length: currentDisplayLength))
        case .binary:
            return(Argon.bitString(of: UInt(bitPattern: Int(field)),length: currentDisplayLength))
            }
        }
    
    private func updateViews(from:VMState)
        {
        self.BPField.stringValue = formattedField(from.BP)
        self.IPField.stringValue = formattedField(from.IP)
        self.SPField.stringValue = formattedField(from.SP)
//        self.GPR0Field.stringValue = formattedField(from.GPR0)
//        self.GPR1Field.stringValue = formattedField(from.GPR1)
//        self.GPR2Field.stringValue = formattedField(from.GPR2)
//        self.GPR3Field.stringValue = formattedField(from.GPR3)
//        self.GPR4Field.stringValue = formattedField(from.GPR4)
//        self.GPR5Field.stringValue = formattedField(from.GPR5)
//        self.GPR6Field.stringValue = formattedField(from.GPR6)
//        self.GPR7Field.stringValue = formattedField(from.GPR7)
//        self.GPR8Field.stringValue = formattedField(from.GPR8)
//        self.GPR9Field.stringValue = formattedField(from.GPR9)
//        self.GPR10Field.stringValue = formattedField(from.GPR10)
//        self.GPR11Field.stringValue = formattedField(from.GPR11)
//        self.GPR12Field.stringValue = formattedField(from.GPR12)
//        self.GPR13Field.stringValue = formattedField(from.GPR13)
//        self.GPR14Field.stringValue = formattedField(from.GPR14)
//        self.GPR15Field.stringValue = formattedField(from.GPR15)
//        self.FPR0Field.stringValue = formattedField(from.FPRS[0])"
//        self.FPR1Field.stringValue = formattedField(from.FPRS[1])"
//        self.FPR2Field.stringValue = formattedField(from.FPRS[2])"
//        self.FPR3Field.stringValue = formattedField(from.FPRS[3])"
//        self.FPR4Field.stringValue = formattedField(from.FPRS[4])"
//        self.FPR5Field.stringValue = formattedField(from.FPRS[5])"
//        self.FPR6Field.stringValue = formattedField(from.FPRS[6])"
//        self.FPR7Field.stringValue = formattedField(from.FPRS[7])"
        let stack = from.stack.map{"\($0)"}
        self.stackListView.list = stack
        self.zeroField.stringValue = "\(from.flagZero)"
        self.ltField.stringValue = "\(from.flagLessThan)"
        self.lteField.stringValue = "\(from.flagLessThanEqual)"
        }
        
    @IBAction func onStepClicked(_ sender:Any?)
        {
//        do
//            {
//            try vm.executeStep()
//            }
//        catch
//            {
//            print("\(error)")
//            }
//        let vmState = vm.state
//        self.updateViews(from: vmState)
//        self.instructionListView.selectedIndex = vmState.IP
//        self.instructionListView.scrollRowToVisible(vmState.IP)
        }
    
    @IBAction func onGoClicked(_ sender:Any?)
        {
        }
    
    @IBAction func onPauseClicked(_ sender:Any?)
        {
        }
    
    @IBAction func onFormatClicked(_ sender:NSSegmentedControl)
        {
        let selectedSegment = sender.selectedSegment
        let label = sender.label(forSegment: selectedSegment)
        switch(label)
            {
            case "HEX":
                currentDisplayFormat = .hexadecimal
            case "BIN":
                currentDisplayFormat = .binary
            default:
                currentDisplayFormat = .decimal
            }
//        self.updateViews(from: vm.state)
        }
    
    @IBAction func onDisplayLengthClicked(_ sender:NSSegmentedControl)
        {
        let selectedSegment = sender.selectedSegment
        let label = sender.label(forSegment: selectedSegment)
        switch(label)
            {
            case "16":
                currentDisplayLength = 16
            case "32":
                currentDisplayLength = 32
            default:
                currentDisplayLength = 64
            }
//        self.updateViews(from: vm.state)
        }
    }
