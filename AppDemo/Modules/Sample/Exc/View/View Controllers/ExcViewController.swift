//
//  ExcViewController.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import JGProgressHUD

class ExcViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = ExcViewModel()
    private let loading = JGProgressHUD(style: .dark)
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customize()
        
        bind()
        
        observe()
    }
    
    private func customize() {
        
    }
    
    private func bind() {
        
        // Observe changes from the viewmodel sections
        // and update the list accordingly
        _ = viewModel.sections.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    private func observe() {
        
        // Update Loader Status
        _ = viewModel.isLoading.asObservable()
            .subscribe(onNext: { [weak this = self] (isloading) in
                guard let this = this else { return }
                _ = isloading
                    ? this.loading.show(in: this.view)
                    : this.loading.dismiss(animated: true)
            })
            .disposed(by: bag)
        
        // Show an error once view model throws one
        _ = viewModel.error.asObservable()
            .subscribe(onNext: { [weak this = self] (error) in
                guard let errorMsg = error else { return }
                this?.presentAlertWithTitle(title: Vocabulary.ErrorNetworkRequest,
                                            message: errorMsg,
                                            options: Vocabulary.Retry,
                                            completion: { _ in
                                                this?.viewModel.loadLatestExchangeRates()
                                            })
            })
            .disposed(by: bag)
        
        // show an error conversion
        _ = viewModel.errorConversion.asObservable()
            .subscribe(onNext: { [weak this = self] (error) in
                guard let errorMsg = error else { return }
                this?.presentAlertWithTitle(title: Vocabulary.ErrorConversion,
                                            message: errorMsg,
                                            options: Vocabulary.OK,
                                            completion: { _ in
                                                
                                            })
            })
            .disposed(by: bag)
        
        // show an success conversion
        _ = viewModel.successConversion.asObservable()
            .subscribe(onNext: { [weak this = self] (amount, conversion, commission) in
                
                // compose success message
                var message = "\(Vocabulary.YouHaveConverted) \(amount) \(Vocabulary.to) \(conversion)."
                
                if let commission = commission {
                    message.append(" \(Vocabulary.CommissionFee) \(commission).")
                }
                
                this?.presentAlertWithTitle(title: Vocabulary.SuccessConversion,
                                            message: message,
                                            options: Vocabulary.OK,
                                            completion: { _ in
                                                
                                            })
            })
            .disposed(by: bag)
    }
    
    private func navigateToCurrencyList() {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let nav = board.instantiateViewController(withIdentifier: CurrencyViewController.navId)
        present(nav, animated: true, completion: nil)
    }

    private func navigateToWalletList() {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let nav = board.instantiateViewController(withIdentifier: WalletViewController.navId)
        present(nav, animated: true, completion: nil)
    }
}

extension ExcViewController {

    // Provide Datasource for the tableview
    public var dataSource: RxTableViewSectionedReloadDataSource<ExcListItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<ExcListItem>(configureCell: { [weak this = self] (source, tableView, indexPath, _) in

            switch source[indexPath] {
            case .excItem(let data):
                let cell = tableView.dequeueReusableCell(withIdentifier: ConversionCell.id, for: indexPath)
                // set cell model data
                (cell as! ConversionCell).data = data; this?.observeCell(cell)
                return cell
            }
        })

        return dataSource
    }
    
    public func observeCell(_ type: AnyObject) {

        if let cell = type as? ConversionCell {

            _ = cell.toCurrencyButton.rx.tap.asObservable()
                .subscribe(onNext: { [weak this = self] (_) in
                    this?.navigateToCurrencyList()
                })
                .disposed(by: cell.bag)
            
            _ = cell.walletButton.rx.tap.asObservable()
                .subscribe(onNext: { [weak this = self] (_) in
                    this?.navigateToWalletList()
                })
                .disposed(by: cell.bag)
            
            _ = cell.submitButton.rx.tap.asObservable()
                .subscribe(onNext: { [weak this = self] (type) in
                    guard let this = this else { return }
                    // dismiss the keyboard first
                    cell.fromField.resignFirstResponder()
                    // get value from the textfield
                    guard let value = Double(cell.fromField.text!), value != 0 else { return }
                    // and process the input
                    this.viewModel.commitConversion(amount: value)
                })
                .disposed(by: cell.bag)
        }
    }
}
