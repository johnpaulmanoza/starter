//
//  Vocabulary.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation

private func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

class Vocabulary {
    
    // Translations happens in this fnx NSLocalizedString()
    
    static let ErrorNetworkRequest = NSLocalizedString("Error Network Request")
    static let ErrorConversion = NSLocalizedString("Failed conversion")
    static let SuccessConversion = NSLocalizedString("Currency converted")
    static let Retry = NSLocalizedString("Retry")
    static let OK = NSLocalizedString("OK")
    static let YouHaveConverted = NSLocalizedString("You have converted")
    static let CommissionFee = NSLocalizedString("Commission Fee - ")
    static let to = NSLocalizedString("to")
}
