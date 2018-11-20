//
//  ViewController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class ArgonSourceFileViewController: NSViewController,Dependent,NSMenuDelegate
    {
    @IBOutlet var sourceEditor:NSTextView!
    
    var vmController:VMWindowController!
    var successfulCompilation:Bool = false
    var memoryWindowController:MemoryWindowController!
    var editorFont:NSFont?
    var tokenizer:SourceTokenizer?
    var package:ArgonModulePart?
    var document:ArgonSourceFile?
        {
        didSet
            {
            update(from: document!)
            }
        }
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.initFonts()
        self.initSource()
        self.initTokenizer()
        self.initMenu()
        }
    
    private func initMenu()
        {
        let mainMenu = NSApplication.shared.mainMenu!
        let projectMenu = mainMenu.item(withTitle: "Project")!.submenu!
        projectMenu.delegate = self
        }
    
    @objc func numberOfItems(in menu: NSMenu) -> Int
        {
        if menu.title == "Project"
            {
            return(menu.numberOfItems)
            }
        else
            {
            return(-1)
            }
        }

    @objc func menu(_ menu:NSMenu,update item:NSMenuItem,at index:Int,shouldCancel:Bool) -> Bool
        {
        if item.title == "Save Executable"
            {
            if package != nil && package!.isExecutable && successfulCompilation
                {
                item.isEnabled = true
                }
            else
                {
                item.isEnabled = false
                }
            }
        else if item.title == "Save Library"
            {
            if package != nil && package!.isLibrary && successfulCompilation
                {
                item.isEnabled = true
                }
            else
                {
                item.isEnabled = false
                }
            }
        return(true)
        }
    
    private func update(from file:ArgonSourceFile)
        {
//        let sourceData = file.
        }
        
    private func initTokenizer()
        {
        tokenizer = SourceTokenizer(editor: sourceEditor)
        tokenizer!.add(dependent: self)
        }
    
    private func initFonts()
        {
        editorFont = NSFont(name:"Menlo-Regular",size:13)
        }
    
    private func initSource()
        {
        sourceEditor.lnv_setUpLineNumberView()
        let path = Bundle.main.path(forResource: "Executable", ofType: "argon")!
        let source = try! String(contentsOfFile: path)
        sourceEditor.font = editorFont
        sourceEditor.string = source
        document?.source = source
        sourceEditor.textStorage?.setAttributes([NSAttributedString.Key(rawValue: "GenericMethodStart"):true], range: NSRange(location: 110,length: 1))
        }
    
    public func update(aspect:String,with:Any?,from:Model)
        {
        if aspect == "tokens"
            {
            document?.tokens = tokenizer?.tokens ?? []
            }
        }

    @IBAction func onForceFlip(_ sender:Any?)
        {
        }
    
    @IBAction func onShowVMClicked(_ sender:Any?)
        {
        let controller = self.storyboard?.instantiateController(withIdentifier: "VMController") as! VMWindowController
        controller.showWindow(self)
        vmController = controller
        }
    
    @IBAction func onInspectMemoryClicked(_ sender:Any?)
        {
        ArgonTests.test()
        }
    
    @IBAction func onBrowseClicked(_ sender:Any?)
        {
        let windowController = self.storyboard?.instantiateController(withIdentifier: "BrowserWindowController") as! BrowserWindowController
        windowController.showWindow(self)
        }
        
    @IBAction func onAllocateClicked(_ sender:Any?)
        {
        }
    
    @IBAction func onRunClicked(_ sender:Any?)
        {
        ArgonTests.test()
        }
    
    @IBAction func onSaveExecutableClicked(_ sender:Any?)
        {
        guard let thePackage = package else
            {
            return
            }
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["argonexe"]
        savePanel.nameFieldStringValue = thePackage.fullName
        savePanel.beginSheetModal(for: self.view.window!)
            {
            modalResponse in
            if modalResponse == .cancel
                {
                return
                }
            var path = savePanel.url!.absoluteURL.path
            if (path as NSString).pathExtension != "argonexe"
                {
                path += ".argonexe"
                }
            NSKeyedArchiver.archiveRootObject(thePackage, toFile: path)
            }
        }
    
    @IBAction func onSaveLibraryClicked(_ sender:Any?)
        {
        }
    
    @IBAction func onBuildClicked(_ sender:Any?)
        {
        successfulCompilation = false
        let compiler = ArgonCompiler()
        do
            {
            compiler.source = sourceEditor.string
            try compiler.parse()
            try compiler.compile()
            successfulCompilation = true
            package = try compiler.package(source: sourceEditor.string)
//            let binaryData = try BinaryEncoder().encode(part)
//            let data = Data(binaryData.bytes)
//            try data.write(to: URL(fileURLWithPath: "/Users/vincent/Desktop/sample.argonexe"))
            if successfulCompilation && package!.isExecutable
                {
                let submenu = NSApplication.shared.mainMenu!.item(withTitle:"Project")!.submenu!
                let item1 = submenu.item(withTitle:"Save Executable")
                item1!.isEnabled = true
                let item2 = submenu.item(withTitle:"Save Library")
                item2!.isEnabled = false
                }
            else if successfulCompilation && package!.isLibrary
                {
                let submenu = NSApplication.shared.mainMenu!.item(withTitle:"Project")!.submenu!
                let item1 = submenu.item(withTitle:"Save Library")
                item1!.isEnabled = true
                let item2 = submenu.item(withTitle:"Save Executable")
                item2!.isEnabled = false
                }
            }
        catch
            {
            print("Error was \(error)")
            }
        }
    
    private func characterIndex(for string:NSAttributedString,at lineNumber:Int) -> NSRange?
        {
        let text = string.string
        let lines = text.split(separator: "\n")
        var line = 1
        var index = 0
        while index < text.count && line < lines.count
            {
            let textLine = lines[line - 1]
            index += textLine.count + 1
            line += 1
            if line == lineNumber
                {
                return(NSRange(location: index + textLine.count,length: lines[line].count))
                }
            }
        return(nil)
        }
    

}

