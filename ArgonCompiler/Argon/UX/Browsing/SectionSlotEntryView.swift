//
//  SectionSlotEntryView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class SectionSlotEntryView:SectionEntryView
    {
    @IBOutlet weak var cartoucheView:CartoucheView!
    @IBOutlet weak var labelWidthConstraint:NSLayoutConstraint!
    @IBOutlet weak var cartoucheWidthConstraint:NSLayoutConstraint!
    
//    public override func awakeFromNib()
//        {
//        super.awakeFromNib()
//        self.cartoucheView.wantsLayer = true
//        self.cartoucheView.layer?.backgroundColor = NSColor.purple.cgColor
//        self.label.wantsLayer = true
//        self.label.layer?.backgroundColor = NSColor.orange.cgColor
//        }
    
//    public override var displayItem:DisplayItem
//        {
//        didSet
//            {
//            super.displayItem = displayItem
//            self.cartoucheView.text = displayItem.traitsName
//            }
//        }
//    
//    public override var maximumRightWidth:CGFloat
//        {
//        didSet
//            {
//            self.cartoucheWidthConstraint.constant = self.maximumRightWidth + 6
//            super.layoutSubtreeIfNeeded()
//            }
//        }
//    
//    public override var maximumLeftWidth:CGFloat
//        {
//        didSet
//            {
//            labelWidthConstraint.constant = maximumLeftWidth
//            super.layoutSubtreeIfNeeded()
//            }
//        }
    }
