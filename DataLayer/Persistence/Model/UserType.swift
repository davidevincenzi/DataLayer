//
//  UserType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 17.10.18.
//

import Foundation

protocol UserType: Storable {
    var name: String? { get set }
}
