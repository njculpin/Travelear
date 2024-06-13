//
//  Arrays.swift
//  Travelear
//
//  Created by Nick Culpin on 12/20/19.
//  Copyright © 2019 thetravelear. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if !contains(element) {
            append(element)
            return (true, element)
        }
        return (false, element)
    }
}
