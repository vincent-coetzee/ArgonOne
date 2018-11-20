//
//  ViewController.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa
import SharedMemory

class ViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource,NSOutlineViewDataSource,NSOutlineViewDelegate,Dependent
    {
    @IBOutlet weak var packagesOutlineView:NSOutlineView!
    @IBOutlet weak var assemblerTableView:NSTableView!
    @IBOutlet weak var topStackView:NSStackView!
    @IBOutlet weak var bottomStackView:NSStackView!
    @IBOutlet weak var conditionSegmentedControl:NSSegmentedControl!
    @IBOutlet weak var stackTableView:NSTableView!
    @IBOutlet weak var stepButton:NSButton!
    
    private var executables:[String:ArgonExecutable] = [:]
    private var libraries:[String:ArgonLibrary] = [:]
    private var linkedPackages:[ArgonLinkedPackage] = []
    private var instructionList:[VMInstruction] = []
    private var registerFields:[NSTextField?] = Array(repeating: nil, count: 38)
    private var mainThread:VMThread!
    private var stackWords:[Word] = []
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.initUnarchiving()
        self.initRegisterFields()
        }

    private func initUnarchiving()
        {
        NSKeyedUnarchiver.setClass(ArgonExecutable.self,forClassName:"Argon.ArgonExecutable")
        NSKeyedUnarchiver.setClass(ArgonClosure.self,forClassName:"Argon.ArgonClosure")
        NSKeyedUnarchiver.setClass(ArgonCodeBlock.self,forClassName:"Argon.ArgonCodeBlock")
        NSKeyedUnarchiver.setClass(ArgonExport.self,forClassName:"Argon.ArgonExport")
        NSKeyedUnarchiver.setClass(ArgonGenericMethod.self,forClassName:"Argon.ArgonGenericMethod")
        NSKeyedUnarchiver.setClass(ArgonMethod.self,forClassName:"Argon.ArgonMethod")
        NSKeyedUnarchiver.setClass(ArgonGlobal.self,forClassName:"Argon.ArgonGlobal")
        NSKeyedUnarchiver.setClass(ArgonImport.self,forClassName:"Argon.ArgonImport")
        NSKeyedUnarchiver.setClass(ArgonLibrary.self,forClassName:"Argon.ArgonLibrary")
        NSKeyedUnarchiver.setClass(ArgonNamedConstant.self,forClassName:"Argon.ArgonNamedConstant")
        NSKeyedUnarchiver.setClass(ArgonParameter.self,forClassName:"Argon.ArgonParameter")
        NSKeyedUnarchiver.setClass(ArgonRelocationTableEntry.self,forClassName:"Argon.ArgonRelocationTableEntry")
        NSKeyedUnarchiver.setClass(ArgonRelocationTable.self,forClassName:"Argon.ArgonRelocationTable")
        NSKeyedUnarchiver.setClass(ArgonString.self,forClassName:"Argon.ArgonString")
        NSKeyedUnarchiver.setClass(ArgonSymbol.self,forClassName:"Argon.ArgonSymbol")
        NSKeyedUnarchiver.setClass(ArgonTraits.self,forClassName:"Argon.ArgonTraits")
        NSKeyedUnarchiver.setClass(CodingInstruction.self,forClassName:"Argon.CodingInstruction")
        NSKeyedUnarchiver.setClass(ArgonLineTrace.self,forClassName:"Argon.ArgonLineTrace")
        NSKeyedUnarchiver.setClass(ArgonSlotLayout.self,forClassName:"Argon.ArgonSlotLayout")
        NSKeyedUnarchiver.setClass(ArgonTypeTemplate.self,forClassName:"Argon.ArgonTypeTemplate")
        }
    
    public func update(aspect: String, with: Any?, from: Model)
        {
        if (from as? VMThread) != nil && aspect == "thread.codeLocation"
            {
            instructionList = []
            let (instructionPointer,instructionCount,IP) = with as! (Pointer,Int,Int32)
            var index:Int32 = 0
            while index < Int32(instructionCount)
                {
                let instruction = VMInstruction(wordAtIndexAtPointer(index,instructionPointer))
                index += 1
                if instruction.mode == .address
                    {
                    instruction.addressWord = wordAtIndexAtPointer(index,instructionPointer)
                    index += 1
                    }
                instructionList.append(instruction)
                }
            assemblerTableView.reloadData()
            assemblerTableView.selectRowIndexes(IndexSet(integer: Int(IP)), byExtendingSelection: false)
            assemblerTableView.scrollRowToVisible(Int(IP))
            }
        }
    
    public func initRegisterFields()
        {
        var innerStackView = topStackView.arrangedSubviews[0] as! NSStackView
        var innerViews = innerStackView.arrangedSubviews
        registerFields[3] = (innerViews[1] as! NSTextField)
        registerFields[2] = (innerViews[3] as! NSTextField)
        innerStackView = topStackView.arrangedSubviews[1] as! NSStackView
        innerViews = innerStackView.arrangedSubviews
        registerFields[1] = (innerViews[1] as! NSTextField)
        registerFields[4] = (innerViews[3] as! NSTextField)
        let stackViews = bottomStackView.arrangedSubviews
        var index = 6
        for view in stackViews
            {
            let stackView = view as! NSStackView
            registerFields[index] = (stackView.arrangedSubviews[1] as! NSTextField)
            index += 1
            registerFields[index] = (stackView.arrangedSubviews[3] as! NSTextField)
            index += 1
            }
        }
    
    private func update(from thread: VMThread)
        {
        for index in Int(6)..<Int(threadRegisterCount(thread.threadMemory)+1)
            {
            registerFields[index]?.stringValue = "\(threadRegisterWordValue(thread.threadMemory,index))"
            }
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1,at: Word(VMThread.kFlagZeroBit), in: thread.conditions) == 1,forSegment: 0)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagLessThanBit), in: thread.conditions) == 1,forSegment: 2)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagLessThanEqualBit), in: thread.conditions) == 1,forSegment: 3)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagEqualBit), in: thread.conditions) == 1,forSegment: 4)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagGreaterThanEqualBit), in: thread.conditions) == 1,forSegment: 5)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagGreaterThanBit), in: thread.conditions) == 1,forSegment: 6)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagNotZeroBit), in: thread.conditions) == 1,forSegment: 1)
        conditionSegmentedControl.setSelected(Argon.valueOf(bits: 1, at: Word(VMThread.kFlagNotEqualBit), in: thread.conditions) == 1,forSegment: 7)
        let threadMemory = thread.threadMemory
        registerFields[2]?.stringValue = "\(threadRegisterWordValue(threadMemory,MachineRegister.SP.rawValue))"
        registerFields[1]?.stringValue = "\(threadRegisterWordValue(threadMemory,MachineRegister.BP.rawValue))"
        registerFields[4]?.stringValue = "\(threadRegisterWordValue(threadMemory,MachineRegister.ST.rawValue))"
        registerFields[3]?.stringValue = "\(thread.IP)"
        }
    
    @IBAction func onStepClicked(_ sender:Any?)
        {
        mainThread.singleStep()
        self.update(from: mainThread)
        self.updateStackTableView(from: mainThread)
        let IP = mainThread.IP
        assemblerTableView.selectRowIndexes(IndexSet(integer: IndexSet.Element(IP)), byExtendingSelection: false)
        }
        
    private func updateStackTableView(from thread:VMThread)
        {
        var words:[Word] = []
        var stackElement = threadRegisterWordValue(thread.threadMemory,MachineRegister.ST.rawValue)
        let stackTop = threadRegisterWordValue(thread.threadMemory,MachineRegister.SP.rawValue)
        while stackElement != stackTop
            {
            words.append(wordAtIndexAtPointer(0,wordAsPointer(stackElement)))
            stackElement -= Word(ArgonWordSize)
            }
        words.append(wordAtIndexAtPointer(0,wordAsPointer(stackElement)))
        stackWords = words
        stackTableView.reloadData()
        }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(linkedPackages.count)
            }
        else if let anItem = item as? ModuleDisplayPart
            {
            return(anItem.childCount)
            }
        return(0)
        }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item == nil
            {
            return(ModulePartHolder(part: linkedPackages[index].module))
            }
        guard let anItem = item as? ModuleDisplayPart else
            {
            fatalError("Should not happen")
            }
        return(anItem.children[index])
        }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        guard let anItem = item as? ModuleDisplayPart else
            {
            fatalError("Should not happen")
            }
        return(anItem.childCount > 0)
        }
    
    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        if tableView == assemblerTableView
            {
            return(instructionList.count)
            }
        else if tableView == stackTableView
            {
            return(stackWords.count)
            }
        return(0)
        }
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        let anItem = item as! ModuleDisplayPart
        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StandardCellView"), owner: nil) as! NSTableCellView
        view.imageView!.image = anItem.icon
        view.textField!.stringValue = anItem.title
        return(view)
        }
    
    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
        self.stepButton.isEnabled = false
        let selectedRow = packagesOutlineView.selectedRow
        let selectedItem = packagesOutlineView.item(atRow: selectedRow)
        let part = selectedItem as! ModuleDisplayPart
        if let codePointer = part.codeBlock
            {
            let wrapper = CodeBlockPointerWrapper(codePointer)
            instructionList = wrapper.instructionList
            self.stepButton.isEnabled = wrapper.runnable
            }
        else
            {
            instructionList = []
            stackWords = []
            self.resetVirtualMachineView()
            }
        assemblerTableView.reloadData()
        stackTableView.reloadData()
        }
    
    private func resetVirtualMachineView()
        {
        for index in Int(6)..<Int(threadRegisterCount(mainThread.threadMemory)+6)
            {
            registerFields[index-6]?.stringValue = ""
            }
        conditionSegmentedControl.setSelected(false,forSegment: 0)
        conditionSegmentedControl.setSelected(false,forSegment: 1)
        conditionSegmentedControl.setSelected(false,forSegment: 2)
        conditionSegmentedControl.setSelected(false,forSegment: 3)
        conditionSegmentedControl.setSelected(false,forSegment: 4)
        conditionSegmentedControl.setSelected(false,forSegment: 5)
        conditionSegmentedControl.setSelected(false,forSegment: 6)
        conditionSegmentedControl.setSelected(false,forSegment: 7)
        registerFields[2]?.stringValue = ""
        registerFields[1]?.stringValue = ""
        registerFields[4]?.stringValue = ""
        registerFields[3]?.stringValue = ""
        }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
        if tableView == assemblerTableView
            {
            let view = assemblerTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AssemblerCellView"), owner: nil) as! NSTableCellView
            view.textField!.stringValue = instructionList[row].disassemble()
            return(view)
            }
        else
            {
            let view = stackTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StackCellView"), owner: nil) as! NSTableCellView
            view.textField!.stringValue = "\(stackWords[row])"
            return(view)
            }
        }
    
    @IBAction func openDocument(_ sender:Any?)
        {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["argonexe","argonlib"]
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModal(for: self.view.window!)
            {
            response in
            if response == .cancel
                {
                return
                }
            let path = openPanel.url!.absoluteURL.path
            do
                {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                let size = (attributes[FileAttributeKey.size] as! NSNumber).intValue
                guard let result = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? ArgonModule else
                    {
                    print("Unabled to load module from file \(path)")
                    return
                    }
                let linker = ArgonLinker()
                linker.packageSizeInBytes = size
                if result.isExecutable
                    {
                    let executable = result as! ArgonExecutable
                    try linker.link(executable: executable,into: VirtualMachine())
                    self.executables[executable.name] = executable
                    }
                else
                    {
                    let library = result as! ArgonLibrary
                    self.libraries[library.name] = library
                    }
                try self.updateView(from: linker)
                }
            catch
                {
                print("\(error)")
                }
            }
        }
    
    private func updateView(from linker:ArgonLinker) throws
        {
        var linkedPackage = linker.linkedPackage()
        linkedPackages.append(linkedPackage)
        packagesOutlineView.reloadData()
        mainThread = try linkedPackage.prepareForRun()
        mainThread?.add(dependent: self)
        }
    }

