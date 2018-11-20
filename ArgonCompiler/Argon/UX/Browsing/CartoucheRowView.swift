//
//  CartoucheRowView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class CartoucheRowView:NSView
    {
    private var cartouches:[CartoucheView] = []
    
    public var names:[String] = []
        {
        didSet
            {
            self.relayout()
            self.needsLayout = true
            self.needsDisplay = true
            }
        }
    
    private func relayout()
        {
        for view in cartouches
            {
            view.removeFromSuperview()
            }
        var last:NSView = self
        for index in 0..<names.count
            {
            let name = names[index]
            let width = NSAttributedString(string: name,attributes: SystemPalette.shared.cartoucheTextAttributes).size().width + 6
            let cartouche = CartoucheView(frame: .zero)
            self.addSubview(cartouche)
            cartouche.text = name
            cartouches.append(cartouche)
            cartouche.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: 4).isActive = true
            cartouche.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
            cartouche.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
            if index != names.count - 1
                {
                self.addConstraint(NSLayoutConstraint(item: cartouche, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
                }
            last = cartouche
            }
        last.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3)
        self.needsLayout = true
        self.needsDisplay = true
        }
    }
