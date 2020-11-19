//
//  UIViewController.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit

extension UIViewController {
    /**
     To easily identify view by their id
    */
    public static var id: String {
        return String(describing: self)
    }
    
    public static var navId: String {
        return String(describing: self) + "Nav"
    }
    
    /**
     To easily display a prompt or alert view
    */
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (_) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIView {
    /**
     Add shadow to a uiview with Material Design specs
     Ref: https://medium.com/material-design-for-ios/part-1-elevation-e48ff795c693
    */
    func elevate(elevation: Double, addBorder: Bool = false, radius: Double = 7.0) {
        if addBorder {
            self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            self.layer.borderWidth = 0.5
        }
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.init(red: 128/255, green: 128/255, blue: 128/255, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: elevation)
        self.layer.shadowRadius = abs(CGFloat(elevation))
        self.layer.shadowOpacity = 0.24
    }
}
