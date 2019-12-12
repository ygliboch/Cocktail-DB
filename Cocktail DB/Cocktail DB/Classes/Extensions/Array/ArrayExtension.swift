//
//  ArrayExtension.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 12.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import Foundation

extension Array where Element == Category {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted(by: { $0.strCategory! > $1.strCategory! }) == other.sorted(by: { $0.strCategory! > $1.strCategory! })
    }
}
