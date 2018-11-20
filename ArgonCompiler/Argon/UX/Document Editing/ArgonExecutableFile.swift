//
//  Document.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

@objc class ArgonExecutableFile: NSDocument
    {
    public override class var readableTypes:[String]
        {
        return(["argonexe"])
        }
    
    public override class var writableTypes:[String]
        {
        return(["argonexe"])
        }
    
    private var documentURL:URL?
    public var executable:ArgonExecutable?
    
    public override var fileType:String?
        {
        get
            {
            return("argonexe")
            }
        set
            {
            }
        }
    override init()
        {
        super.init()
        }

    override class var autosavesInPlace: Bool
        {
        return true
        }
    
    public override func fileNameExtension(forType typeName: String,saveOperation: NSDocument.SaveOperationType) -> String?
        {
        if typeName == "argon"
            {
            return(".argon")
            }
        else if typeName == "argonexe"
            {
            return(".argonexe")
            }
        else if typeName == "argonlib"
            {
            return(".argonlib")
            }
        else
            {
            return(nil)
            }
        }
    override func makeWindowControllers()
        {
//         Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ArgonExecutableFileWindowController")) as! ArgonExecutableFileWindowController
        self.addWindowController(windowController)
        windowController.executableFileViewController.document = self
        }

    override func read(from url: URL, ofType typeName: String) throws
        {
        documentURL = url
        }
    
    private func binaryEncode<T:Encodable>(_ something:T) throws -> Data
        {
        let binaryData = try BinaryEncoder().encode(something)
        let data = Data(binaryData.bytes)
        return(data)
        }
    
    private func binaryDecode<T:Decodable>(_ data:Data) throws -> T
        {
        let binaryData = EncodedData(bytes: Array<UInt8>(data))
        let object = try BinaryDecoder().decode(T.self, from: binaryData)
        return(object)
        }
    
    override open func write(to url: URL, ofType typeName: String) throws
        {
        }
    }

