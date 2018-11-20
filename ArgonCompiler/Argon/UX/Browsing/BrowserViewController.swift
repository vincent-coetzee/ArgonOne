//
//  BrowserViewController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class BrowserViewController: NSViewController,NSSplitViewDelegate,NSBrowserDelegate
    {
    @IBOutlet weak var topView:NSView!
    @IBOutlet weak var editor:NSTextView!
    @IBOutlet weak var splitView:NSSplitView!
    
    private var root = RootDisplayWrapper()
    private var maximumTraitsFieldWidth:CGFloat = 0
    private var leftSection:SectionTreeView?
    private var middleSection:SectionTreeView?
    private var rightSection:SectionTreeView?
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.initSections()
        ArgonRepository.shared.add(dependent: self)
        }
    
    private func initSections()
        {
        let nib = NSNib(nibNamed: "SectionTreeView", bundle: nil)!
        var pointer = UnsafeMutablePointer<NSArray?>.allocate(capacity: 1)
        var objects = AutoreleasingUnsafeMutablePointer<NSArray?>(pointer)
        let leftNib = NSNib(nibNamed: "SectionTreeView", bundle: nil)!
        leftNib.instantiate(withOwner: nil, topLevelObjects: objects)
        leftSection = ((objects.pointee!.filter{$0 is SectionTreeView})[0] as! SectionTreeView)
        leftSection?.text = "Modules"
        leftSection?.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(leftSection!)
        leftSection!.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        leftSection!.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        leftSection!.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        var constraint = NSLayoutConstraint(item: leftSection!, attribute: .trailing, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 0.25, constant: 0)
        topView.addConstraint(constraint)
        pointer = UnsafeMutablePointer<NSArray?>.allocate(capacity: 1)
        objects = AutoreleasingUnsafeMutablePointer<NSArray?>(pointer)
        nib.instantiate(withOwner: nil, topLevelObjects: objects)
        middleSection = ((objects.pointee!.filter{$0 is SectionTreeView})[0] as! SectionTreeView)
        leftSection!.add(dependent: middleSection!)
        middleSection?.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(middleSection!)
        middleSection!.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        middleSection!.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        constraint = NSLayoutConstraint(item: middleSection!, attribute: .leading, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 0.25, constant: 0)
        topView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: middleSection!, attribute: .trailing, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 0.5, constant: 0)
        topView.addConstraint(constraint)
        pointer = UnsafeMutablePointer<NSArray?>.allocate(capacity: 1)
        objects = AutoreleasingUnsafeMutablePointer<NSArray?>(pointer)
        nib.instantiate(withOwner: nil, topLevelObjects: objects)
        rightSection = ((objects.pointee!.filter{$0 is SectionTreeView})[0] as! SectionTreeView)
        middleSection!.add(dependent: rightSection!)
        rightSection?.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(rightSection!)
        rightSection!.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        rightSection!.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        constraint = NSLayoutConstraint(item: rightSection!, attribute: .leading, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 0.5, constant: 0)
        topView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: rightSection!, attribute: .width, relatedBy: .equal, toItem: topView, attribute: .width, multiplier: 0.5, constant: 0)
        topView.addConstraint(constraint)
        rightSection!.trailingAnchor.constraint(equalTo: topView.trailingAnchor)
        }
    
     public func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat
        {
        if dividerIndex == 0
            {
            let viewHeight = self.view.bounds.height
            let browserMinHeight = 0.2 * viewHeight
            if proposedMinimumPosition < browserMinHeight
                {
                return(browserMinHeight)
                }
            }
        return(proposedMinimumPosition)
        }
    
    public func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat
        {
        if dividerIndex == 0
            {
            let viewHeight = self.view.bounds.height
            let browserMaxHeight = 0.6 * viewHeight
            if proposedMaximumPosition > browserMaxHeight
                {
                return(browserMaxHeight)
                }
            }
        return(proposedMaximumPosition)
        }
    }

extension BrowserViewController:Dependent
    {
    public func update(aspect:String,with:Any?,from:Model)
        {
//        if aspect == "executableNodes"
//            {
//            var items = DisplayItemList()
//            for name in ArgonRepository.shared.executableNames
//                {
//                let executable = ArgonRepository.shared.executable(at: name)
//                let item = ExecutableDisplayWrapper(executable: executable!)
//                items.append(item)
//                }
//            leftSection?.items  = items
//            }
        }
    }
