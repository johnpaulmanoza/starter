//
//  CurrencyViewModel.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

public class CurrencyViewModel {
    
    // MARK: Public
    var sections: PublishSubject<[CurrencyListItem]> = PublishSubject()
    var isLoading: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var error: PublishSubject<String?> = PublishSubject()
    
    // MARK: Private
    private var items: [Currency] = []
    private let excService = ExcService()
    private let bag = DisposeBag()
    
    init() {
        
        // and display the results
        let realm = try! Realm()
        let items = realm.objects(Currency.self)

        // Observe changes in the list of currencies in local db
        _ = Observable
            .array(from: items)
            .subscribe(onNext: { [weak this = self] nextItems in
                this?.items = nextItems
                // run on main thread and make sure to add delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   this?.showItems()
                }
            })
            .disposed(by: bag)
    }
    
    /**
     
    Display list items by iterating the currency results and converting them to UI Model Classes
     
     */
    private func showItems() {
        
        let listItems = items
            .map { CurrencyCellItem(currency: $0) }
            .map { CurrencyListItem.Row.currencyItem(item: $0) }
        
        sections.onNext([
            CurrencyListItem.listSection(header: "", items: listItems)
        ])
    }
    
    /**
     
    Store the selected currency for conversion
     
    - Parameters:
     - currencySymbol: Selected currency symbol
     
     */
    func storeSelectedCurrency(currencySymbol: String) {
        
        excService.storeSelectedCurrency(currencySymbol: currencySymbol)
    }
}
