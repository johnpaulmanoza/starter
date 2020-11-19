//
//  WalletCell.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/9/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit

class WalletCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var flagIconImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    var data: WalletCellItem? {
        didSet {
            
            let formatter = NumberFormatter(); formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2; formatter.maximumFractionDigits = 2
            
            // display wallet data
            if let wallet = data?.wallet {
                flagIconImageView.image = UIImage(named: wallet.walletBalanceCurrency)
                let amountFormatted = formatter.string(from: (wallet.walletBalanceAmount) as NSNumber) ?? ""
                totalBalanceLabel.text = amountFormatted
                currencyNameLabel.text = wallet.walletBalanceCurrency
            }
            
            // display balance data
            if let balance = data?.balance {
                flagIconImageView.image = UIImage(named: balance.balanceCurrency)
                let amountFormatted = formatter.string(from: (balance.balanceAmount) as NSNumber) ?? ""
                totalBalanceLabel.text = amountFormatted
                currencyNameLabel.text = balance.balanceCurrency
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        customize()
    }
    
    private func customize() {
        
        // modify layout styles
        containerView.elevate(elevation: 8.0, addBorder: false, radius: 5.0)
        flagIconImageView.elevate(elevation: 5.0)
    }
}
