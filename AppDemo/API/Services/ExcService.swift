//
//  ExcService.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

public class ExcService {
    
    private let manager = APIManager()

    init() {
       
    }
    
    /**
     Convert currency
   
     - Parameters:
        - sellAmount: amounth to convert
        - rate: conversion rate

     - Returns:
        - Converted amount
     
    */
    func convert(sellAmount: Double, rate: Double) -> Double {
       return sellAmount * rate
    }
       
   /**
     Convert currency with commission rate
    
     - Parameters:
        - sellAmount: amounth to convert
        - rate: conversion rate
        - commissionRate: charge for conversion (should be in percentage, e.g. if 7% etc)
    
     - Returns:
        - total conversion rate and commission fee
    
    */
    func convertWithComission(sellAmount: Double, rate: Double, commissionRate: Double) -> Double {
       let conversion = convert(sellAmount: sellAmount, rate: rate)
       let commissionFee = (commissionRate / 100) * sellAmount
       return conversion + commissionFee
    }
    
    /**
     Compute commission fee
    
     - Parameters:
        - sellAmount: amounth to convert
        - commissionRate: charge for conversion (should be in percentage, e.g. if 7% etc)
    
     - Returns:
        - commission amount
    
    */
    func computeCommissionFee(sellAmount: Double, commissionRate: Double) -> Double {
        return (commissionRate / 100) * sellAmount
    }
    
    /**
     
    Load latest exchange rates from the API
     
     */
    func loadLatestExchangeRates() -> Observable<Any> {
        return manager
            .requestObject(ExcRouter.loadExchangeRates, ExcRate.self)
            .map({ [weak this = self] (items) -> Any in
                guard let rates = items as? ExcRate else { return items }

                // store results to local database first
                this?.storeExcRate(item: rates)
                
                return items
            })
            .asObservable()
    }

    /**
     
    Persist exchange rates into local database
     
     - Parameters:
        - item: object to store
    */
    private func storeExcRate(item: ExcRate) {
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.create(ExcRate.self, value: item, update: .all)
            }
            
            // seed currency objects
            let values = [item.exchangeRateAUD,
                          item.exchangeRateCAD,
                          item.exchangeRateJPY,
                          item.exchangeRateUSD,
                          item.exchangeRatePHP,
                          item.exchangeRateGBP]
            
            let indices = ["AUD",
                           "CAD",
                           "JPY",
                           "USD",
                           "PHP",
                           "GBP"]
        
            _ = try zip(values, indices)
                .map { (value, key) -> Void in
                    
                    guard
                        let currency = realm.objects(Currency.self).filter("currencySymbol == '\(key)'").first
                    else
                        { return }
                    
                    // update currency
                    try realm.write {
                        currency.currencyRate = value
                    }
                }
            
            // seed wallet object if has no value
            if realm.objects(Wallet.self).count == 0 {
                let initialWallet = Wallet()
                initialWallet.walletBalanceCurrency = "EUR"
                initialWallet.walletId = 1 // user id is preferred
                try realm.write {
                    initialWallet.walletBalanceAmount = 1000.0 // initial balance of 1000 EUR
                    realm.create(Wallet.self, value: initialWallet, update: .all)
                }
            }
            
        } catch _ {

        }
    }
    
    /**
        
     Reset delivery items table
     
     */
    private func resetExcRateItems() {
        
        do {
            let realm = try Realm()
            try realm.write {
                let items = realm.objects(ExcRate.self); realm.delete(items)
            }
        } catch _ {

        }
    }
    
    /**
     
    Store the selected currency for conversion
     
    - Parameters:
     - currencySymbol: Selected currency symbol
     
     */
    func storeSelectedCurrency(currencySymbol: String) {
        
        do {
            
            let realm = try Realm()
            
            let currencies = realm.objects(Currency.self)
            
            guard
                let selectedCurrency = currencies.filter("currencySymbol == '\(currencySymbol)'").first
            else
                { return }
            
            // remove previous selections
            _ = try currencies.map({ (item) -> Void in
                try realm.write {
                    item.currencyIsSelected = false
                }
            })
            
            // set current selection
            try realm.write {
                selectedCurrency.currencyIsSelected = true
            }
            
        } catch _ {

        }
    }
    
    /**
     Get selected currency
     */
    func selectedCurrency() -> Currency? {
        
        do {
            
            let realm = try Realm()
            let currencies = realm.objects(Currency.self)
            
            guard
                let selectedCurrency = currencies.filter("currencyIsSelected == true").first
            else
                { return nil }
            
            return selectedCurrency
            
        } catch _ {

            return nil
        }
    }
    
    func currentWallet() -> Wallet? {
        
        do {
               
            let realm = try Realm()
            let currentWallet = realm.objects(Wallet.self).first
            
            return currentWallet
            
        } catch _ {
            
            return nil
        }
    }
    
    /**
    Deduct an amount into the current wallet
     
     - Parameters:
        - amount: Amount to add into the balance
     */
    private func deductAmountToCurrentWallet(amount: Double) {
        
        do {
            
            let realm = try Realm()
            
            guard
                let currentWallet = realm.objects(Wallet.self).first
            else
                { return }
            
            let newAmount = currentWallet.walletBalanceAmount - amount
            
            try realm.write {
                currentWallet.walletBalanceAmount = newAmount
            }
            
        } catch _ {

        }
    }
    
    /**
    Add rules here when to apply a fee when doing a conversion
     */
    private func shoulApplyFeeForConversion() -> Bool {
        
        // First 5 conversions are free otherwise it comes for a fee
        if let wallet = currentWallet() {
            return wallet.walletTotalConversions > 4
        }
        
        return false
    }
    
    /**
    Create a new balance or update an existing balance in the wallet
     
     - Parameters:
        - amount: Amount to add into the balance
        - symbol: Currency where to put this balance
     */
    private func createUpdateBalance(amount: Double, symbol: String) {
        
        do {
            
            let realm = try Realm()
            guard let currentWallet = realm.objects(Wallet.self).first else { return }
            
            var balance: Balance!
            var isNew = false
            
            // get or create a new balance
            if let existingBalance = currentWallet.walletBalances.filter("balanceCurrency == '\(symbol)'").first {
                balance = existingBalance; isNew = false
            } else {
                balance = Balance(); isNew = true
            }

            try realm.write {
                
                // track number of conversions
                currentWallet.walletTotalConversions = currentWallet.walletTotalConversions + 1
                
                // update balance amount or set
                if isNew == false {
                    balance.balanceAmount = balance.balanceAmount + amount
                } else {
                    balance.balanceAmount = amount
                }
                
                if isNew {
                    // update balance currency symbol
                    balance.balanceCurrency = symbol
                    
                    // update current wallet
                    currentWallet.walletBalances.append(balance)
                }
                
                // store balance
                realm.create(Balance.self, value: balance!, update: .all)
            }
            
        } catch _ {

        }
    }
    
    /**
    Commit the conversion
     
     - Parameters:
        - amount: Amount to convert
        - commissionRate: commission fee in percentage (e.g. 0.7%)
        - completion:completion block
     */
    typealias conversionHandler = (_ amountDesc: String?, _ convertedDesc: String?, _ commissionDesc: String?, _ error: String?) -> Void
    func commitConversion(amount: Double, commissionRate: Double = 0.7, completion: conversionHandler) {
        
        guard let currentRate = selectedCurrency()?.currencyRate, let currentSymbol = selectedCurrency()?.currencySymbol, let wallet = currentWallet(), let walletSymbol = currentWallet()?.walletBalanceCurrency else {
            completion(nil, nil, nil, "No selected currency")
            return
        }
        
        let commissionFee = computeCommissionFee(sellAmount: amount, commissionRate: commissionRate)
        
        // 1 Check if wallet has the sufficient value before conversion to avoid negative values
        guard wallet.walletBalanceAmount > (amount + commissionFee) else {
            completion(nil, nil, nil, "Insufficient Balance")
            return
        }
        
        // 2. Conversion
        let shoulApplyFee = shoulApplyFeeForConversion()
        let convertedValue = convert(sellAmount: amount, rate: currentRate)
        
        // 3. Deduct value to current wallet
        let deductions = shoulApplyFee ? amount + commissionFee : amount
        deductAmountToCurrentWallet(amount: deductions)

        // 4. Create a balance to new/existing wallet
        createUpdateBalance(amount: convertedValue, symbol: currentSymbol)
        
        // 5. Display results, return the commission only if needed
        
        // format the values first
        let formatter = NumberFormatter(); formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2; formatter.maximumFractionDigits = 2
        let amountFormatted = formatter.string(from: (amount) as NSNumber) ?? ""
        let convertedFormatted = formatter.string(from: (convertedValue) as NSNumber) ?? ""
        let commissionFormatted = formatter.string(from: (commissionFee) as NSNumber) ?? ""
        
        let amounthDesc = "\(amountFormatted) \(walletSymbol)" // e.g. 100 EUR has been converted to
        let convertedDesc = "\(convertedFormatted) \(currentSymbol)" // 128 USD
        let commissionDesc = shoulApplyFee ? "\(commissionFormatted) \(walletSymbol)" : nil // with commission of
        completion(amounthDesc, convertedDesc, commissionDesc, nil)
    }
}
