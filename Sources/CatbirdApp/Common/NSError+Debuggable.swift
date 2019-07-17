//
//  NSError+Debuggable.swift
//  App
//
//  Created by Alexander Ignatev on 18/06/2019.
//

import Vapor
import Foundation

extension NSError: Debuggable {

    public var identifier: String {
        return "\(domain): \(code)"
    }

    public var reason: String {
        return localizedDescription
    }
}
