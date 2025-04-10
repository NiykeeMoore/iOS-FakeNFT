//
//  CartSortType.swift
//  FakeNFT
//
//  Created by Niykee Moore on 05.04.2025.
//

import UIKit

enum CartSortType: CaseIterable {
    case priceDescending
    case nameDescending
    case raitingDescending
    case cancel
    
    var title: String {
        switch self {
        case .priceDescending:
            return "По цене"
        case .nameDescending:
            return "По названию"
        case .raitingDescending:
            return "По рейтингу"
        case .cancel:
            return "Закрыть"
        }
    }
}
