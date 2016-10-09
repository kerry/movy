//
//  FetchLocalizedString.swift
//  Movy
//
//  Created by Prateek Grover on 09/10/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
