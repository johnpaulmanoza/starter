//
//  RealmSwift.swift
//  AppDemo
//
//  Created by John Paul Manoza on 11/19/20.
//

import Foundation
import RealmSwift

class RealmManager {

    init() {
        
    }

    convenience init(mockedRealm: Realm) {
        self.init()
    }
    
    // Set initial schema version, useful for migration later
    private func schemaVersion() -> UInt64 {
        return 1
    }
    
    public func config() {
        
        let config = Realm.Configuration(schemaVersion: schemaVersion(), migrationBlock: { migration, oldSchemaVersion in })
        Realm.Configuration.defaultConfiguration = config
        
        // seed initial data
        seedData()
        
        print("Realm path -->", config.fileURL?.absoluteString ?? "File can't found")
    }
    
    public func seedData() {
        
        let symbols = ["CAD", "AUD", "JPY", "USD", "PHP", "GBP"]
        
        do {

            let realm = try Realm()
            
            // Skip seeding if table have contents
            guard realm.objects(Currency.self).count == 0 else { return }
            
            let items = symbols
                .map({ (symbol) -> Currency in
                    let item = Currency()
                    item.currencySymbol = symbol
                    item.currencyIsSelected = symbol == "USD" // initial selected value is USD
                    return item
                })
            
            try realm.write {
                _ = items.map { realm.create(Currency.self, value: $0, update: .all) }
            }
            
        } catch _ {

        }
    }
}
