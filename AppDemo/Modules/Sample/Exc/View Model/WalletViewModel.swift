//
//  WalletViewModel.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

public class WalletViewModel {
    
    // MARK: Public
    var sections: PublishSubject<[WalletListItem]> = PublishSubject()
    
    // MARK: Private
    private let excService = ExcService()
    private var items: [Balance] = []
    private var wallet: Wallet?
    private let bag = DisposeBag()
    
    init() {
        
        // and display the results
        let realm = try! Realm()
        let items = realm.objects(Balance.self)
        
        // set current value
        wallet = excService.currentWallet()

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
     Display list items by iterating the wallet results and converting them to UI Model Classes
     */
    private func showItems() {
        
        var listItems = items
            .map { WalletCellItem(balance: $0) }
            .map { WalletListItem.Row.walletItem(item: $0) }
        
        if let wallet = wallet {
            let item = WalletCellItem(wallet: wallet)
            listItems.insert(WalletListItem.Row.walletItem(item: item), at: 0)
        }
        
        sections.onNext([
            WalletListItem.listSection(header: "", items: listItems)
        ])
    }
}
