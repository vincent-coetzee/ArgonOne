//
//  Document.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

@objc class ArgonSourceFile: NSDocument
    {
    private var bundleWrapper:FileWrapper?
    private var documentURL:URL?
    public var source:String = ""
        {
        didSet
            {
            sourceChanged = true
            }
        }
    private var sourceChanged = false
    public var tokens:[Token] = []
        {
        didSet
            {
            tokensChanged = true
            }
        }
    private var tokensChanged = false
    public override var fileType:String?
        {
        get
            {
            return("argon")
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
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ArgonSourceFileWindowController")) as! ArgonSourceFileWindowController
        self.addWindowController(windowController)
        windowController.sourceFileViewController.document = self
        }

    override func read(from url: URL, ofType typeName: String) throws
        {
        documentURL = url
        bundleWrapper = try FileWrapper(url: url, options: [.immediate])
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
        if bundleWrapper == nil
            {
            guard let sourceData = source.data(using: .utf8) else
                {
                throw(ArgonSystemError.sourceFailedUTF8Conversation)
                }
            let sourceWrapper = FileWrapper(regularFileWithContents: sourceData)
            sourceWrapper.preferredFilename = "source.txt"
            let tokenData = try self.binaryEncode(tokens)
            let tokenWrapper = FileWrapper(regularFileWithContents: tokenData)
            tokenWrapper.preferredFilename = "tokens.bin"
            let wrappers = ["source.text":sourceWrapper,"tokens.bin":tokenWrapper]
            let wrapper = FileWrapper(directoryWithFileWrappers: wrappers)
            try wrapper.write(to: url, options: [.atomic,.withNameUpdating], originalContentsURL: documentURL)
            }
        else
            {
            }
        }
    }

