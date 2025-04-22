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
            return NSLocalizedString("cart_nav_sortAlert_priceDescending", comment: "")
        case .nameDescending:
            return NSLocalizedString("cart_nav_sortAlert_nameDescending", comment: "")
        case .raitingDescending:
            return NSLocalizedString("cart_nav_sortAlert_raitingDescending", comment: "")
        case .cancel:
            return NSLocalizedString("cart_nav_sortAlert_cancel", comment: "")
        }
    }
}
