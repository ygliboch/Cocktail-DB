//
//  Drink.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 12.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import Foundation

struct Drinks: Codable {
    var drinks: [Drink]?
}

struct Drink: Codable {
    var idDrink: String?
    var strDrink: String?
    var strDrinkThumb: String?
}
