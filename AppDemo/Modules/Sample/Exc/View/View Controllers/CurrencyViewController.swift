//
//  CurrencyViewController.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import JGProgressHUD

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = CurrencyViewModel()
    private let loading = JGProgressHUD(style: .dark)
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customize()
        
        bind()
        
        observe()
    }
    
    private func customize() {
        
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
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
        _ = navigationItem.rightBarButtonItem?.rx.tap.asObservable()
            .subscribe(onNext: { [weak this = self] (_) in
                this?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    
        // Observe row selections
        _ = Observable.zip(
                tableView.rx.itemSelected,
                tableView.rx.modelSelected(CurrencyListItem.Row.self)
            )
            .subscribe(onNext: { [weak this = self] (indexPath, model) in
                this?.tableView.deselectRow(at: indexPath, animated: true)
                switch model {
                case .currencyItem(let data):
                    guard let currency = data.currency else { return }
                    // store the selected
                    this?.viewModel.storeSelectedCurrency(currencySymbol: currency.currencySymbol)
                    this?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: bag)
    }
}

extension CurrencyViewController {

    // Provide Datasource for the tableview
    public var dataSource: RxTableViewSectionedReloadDataSource<CurrencyListItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<CurrencyListItem>(configureCell: { (source, tableView, indexPath, _) in

            switch source[indexPath] {
            case .currencyItem(let data):
                let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.id, for: indexPath)
                // set cell model data
                (cell as! CurrencyCell).data = data
                return cell
            }
        })

        return dataSource
    }
}

