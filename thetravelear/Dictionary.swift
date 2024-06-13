//
//  Dictionary.swift
//  Travelear
//
//  Created by Nick Culpin on 2/29/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

extension Dictionary {
    /// Utility method for printing Dictionaries as pretty-printed JSON.
    var jsonString: String? {
      if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
        let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
      }
      return nil
    }
}
