//
//  CurrencyCell.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    
    @IBOutlet weak var flagIconImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyRateLabel: UILabel!
    
    public var data: CurrencyCellItem? {
        didSet {
            guard let currency = data?.currency else { return }
            flagIconImageView.image = UIImage(named: currency.currencySymbol)
            currencyNameLabel.text = currency.currencySymbol
            currencyRateLabel.text = "\(currency.currencyRate)"
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        customize()
    }
    
    private func customize() {
        
        // modify layout styles
        flagIconImageView.elevate(elevation: 5.0)
    }
}
