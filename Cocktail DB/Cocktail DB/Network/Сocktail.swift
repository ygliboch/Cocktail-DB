//
//  Сocktail.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 12.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import Foundation
import Moya

enum Cocktail {
    
    case categories
    case coctails(String)
}

extension Cocktail: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://www.thecocktaildb.com/api/json/v1/1")!
    }
    
    var path: String {
        switch self {
        case .categories:
            return "/list.php"
        case .coctails:
            return "/filter.php"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .categories:
            let parametrs = ["c" : "list"]
            return .requestParameters(parameters: parametrs, encoding: URLEncoding.default)
        case .coctails(let category):
            let parametrs = ["c" : category]
            return .requestParameters(parameters: parametrs, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    public var validationType: ValidationType {
      return .successCodes
    }
}
