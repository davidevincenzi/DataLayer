//
//  Errors.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//

import Foundation

enum DataLayerError: Error {
    case general(String)
    case persistence(String)
}
