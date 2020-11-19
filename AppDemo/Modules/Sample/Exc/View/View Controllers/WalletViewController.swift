//
//  WalletViewController.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import JGProgressHUD

class WalletViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = WalletViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customize()
        
        bind()
        
        observe()
    }
    
    private func customize() {
        
        tableView.rowHeight = 166
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
    }
}

extension WalletViewController {

    // Provide Datasource for the tableview
    public var dataSource: RxTableViewSectionedReloadDataSource<WalletListItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<WalletListItem>(configureCell: { (source, tableView, indexPath, _) in

            switch source[indexPath] {
            case .walletItem(let data):
                let cell = tableView.dequeueReusableCell(withIdentifier: WalletCell.id, for: indexPath)
                // set cell model data
                (cell as! WalletCell).data = data
                return cell
            }
        })

        return dataSource
    }
}

