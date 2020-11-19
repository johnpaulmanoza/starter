//
//  ConversionCell.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/9/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import RxSwift

class ConversionCell: UITableViewCell {

    @IBOutlet weak var conversionView: UIView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var fromCurrencyButton: UIButton!
    @IBOutlet weak var toCurrencyButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    
    
    var data: ExcCellItem? {
        didSet {
            guard let data = data else { return }
            
            // display balance
            totalBalanceLabel.text = data.currentBalance
            
            // display inputs
            fromField.text = data.fromValue ?? ""
            toField.text = data.toValue ?? ""
            
            // set button titles
            fromCurrencyButton.setTitle(data.fromCurrencySymbol ?? "", for: .normal)
            toCurrencyButton.setTitle(data.toCurrencySymbol ?? "", for: .normal)
        }
    }
    
    private(set) var bag = DisposeBag()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        customize()
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        bag = DisposeBag()
    }
    
    private func customize() {
        
        // modify layout styles
        conversionView.elevate(elevation: 8.0, addBorder: false, radius: 5.0)
        
        submitButton.elevate(elevation: 3.0, addBorder: false, radius: 5.0)
        fromField.elevate(elevation: 3.0, addBorder: false, radius: 5.0)
        toField.elevate(elevation: 3.0, addBorder: false, radius: 5.0)
        fromCurrencyButton.elevate(elevation: 3.0, addBorder: false, radius: 5.0)
        toCurrencyButton.elevate(elevation: 3.0, addBorder: false, radius: 5.0)
        walletButton.elevate(elevation: 2.0, addBorder: false, radius: 5.0)
    }
}
