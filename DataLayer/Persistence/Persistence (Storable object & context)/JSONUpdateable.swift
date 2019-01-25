//
//  JSONUpdateable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation

protocol JSONUpdateable: class {
    //func updateRelationshipsWithJSONDictionary(_ dictionary: JSONDictionary) throws
    //func updateUntrackedNestedObjects(_ dictionary: JSONDictionary)
    //func isValid() -> Bool
    
    func value(forKey key: String) -> Any?
    func setValue(_ value: Any?, forKey key: String)
}
