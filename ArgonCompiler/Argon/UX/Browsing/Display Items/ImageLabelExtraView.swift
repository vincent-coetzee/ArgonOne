//
//  ImageLabelView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class ImageLabelExtraView: NSView
    {
    private var image:NSImageView!
    private var label:NSTextField!
    private var labelWidthConstraint:NSLayoutConstraint!
    private var extraViewWidthConstraint:NSLayoutConstraint!
    
    public var extraView:NSView = NSView(frame:.zero)
    
    public override init(frame:NSRect)
        {
        super.init(frame:frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.initSubviews()
        self.initConstraints()
        }
    
    public func set(displayItem:DisplayItem,extraViewWidth:CGFloat)
        {
        self.image.image = displayItem.iconImage
        self.label.stringValue = displayItem.name
        if displayItem.contentType == .slot
            {
            let cartoucheView = CartoucheView(frame: .zero)
            cartoucheView.translatesAutoresizingMaskIntoConstraints = false
            cartoucheView.text = (displayItem.nakedItem as! ArgonSlotNode).traits.name.string
            self.replaceExtraView(with: cartoucheView,width:extraViewWidth)
            }
        }
    
    private func replaceExtraView(with newView: NSView,width:CGFloat)
        {
        extraView.removeFromSuperview()
        self.addSubview(newView)
        extraView = newView
        self.extraView.leadingAnchor.constraint(equalTo: self.label.trailingAnchor).isActive = true
        self.extraView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.extraView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.extraView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.extraView.wantsLayer = true
        self.extraView.layer!.backgroundColor = NSColor.purple.cgColor
        self.addConstraint(NSLayoutConstraint(item: self.extraView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
        self.layoutSubtreeIfNeeded()
        }
    
    required init?(coder decoder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
    private func initSubviews()
        {
        self.image = NSImageView(frame: .zero)
        self.image.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.image)
        self.label = NSTextField(labelWithString: "")
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.label)
        self.extraView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.extraView)
        }
    
    private func initConstraints()
        {
        self.image.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.image.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.image.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.addConstraint(NSLayoutConstraint(item: self.image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        self.label.leadingAnchor.constraint(equalTo: self.image.trailingAnchor).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: extraView.leadingAnchor).isActive = true
        self.label.wantsLayer = true
        self.label.layer!.backgroundColor = NSColor.orange.cgColor
        self.extraView.leadingAnchor.constraint(equalTo: self.label.trailingAnchor).isActive = true
        self.extraView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.extraView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.extraView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.addConstraint(NSLayoutConstraint(item: self.extraView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
        self.extraView.wantsLayer = true
        self.extraView.layer!.backgroundColor = NSColor.purple.cgColor
        }
    }
