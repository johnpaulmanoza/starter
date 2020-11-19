//
//  WalletListItem.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/9/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import RxDataSources

enum WalletListItem: SectionModelType {

    typealias Item = Row

    // Declare different tableview sections here
    case listSection(header: String, items: [Row])

    enum Row {
        // Declare different cell layout here
        case walletItem(item: WalletCellItem)
    }

    // conformance to SectionModelType
    var items: [Row] {
        switch self {
        case .listSection(_, let items):
            return items
        }
    }

    public init(original: WalletListItem, items: [Row]) {
        switch original {
        case .listSection(let header, _):
            self = .listSection(header: header, items: items)
        }
    }
}

// Create a UI model class, to differentiate data per UI class

class WalletCellItem {

    var wallet: Wallet?
    var balance: Balance?
    
    init(wallet: Wallet?) {
        self.wallet = wallet
    }
    
    init(balance: Balance?) {
        self.balance = balance
    }
}

