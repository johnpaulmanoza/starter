//
//  ExcListItem.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/9/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import RxDataSources

enum ExcListItem: SectionModelType {

    typealias Item = Row

    // Declare different tableview sections here
    case listSection(header: String, items: [Row])

    enum Row {
        // Declare different cell layout here
        case excItem(item: ExcCellItem)
    }

    // conformance to SectionModelType
    var items: [Row] {
        switch self {
        case .listSection(_, let items):
            return items
        }
    }

    public init(original: ExcListItem, items: [Row]) {
        switch original {
        case .listSection(let header, _):
            self = .listSection(header: header, items: items)
        }
    }
}

// Create a UI model class, to differentiate data per UI class

class ExcCellItem {

    var currentBalance: String?
    var fromCurrencySymbol: String?
    var toCurrencySymbol: String?
    
    var fromValue: String?
    var toValue: String?

    init(currentBalance: String?, fromCurrencySymbol: String?, toCurrencySymbol: String?, fromValue: String?, toValue: String?) {
        self.currentBalance = currentBalance
        self.fromCurrencySymbol = fromCurrencySymbol
        self.toCurrencySymbol = toCurrencySymbol
        self.fromValue = fromValue
        self.toValue = toValue
    }
}

