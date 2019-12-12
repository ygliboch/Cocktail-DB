//
//  Сategory.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 11.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import Foundation

struct Categories: Codable {
    var drinks: [Category]?
}

struct Category: Codable, Equatable, Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.strCategory == rhs.strCategory
    }
    
    var strCategory: String?
}
