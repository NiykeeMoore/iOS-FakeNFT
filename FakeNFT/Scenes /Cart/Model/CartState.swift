//
//  CartState.swift
//  FakeNFT
//
//  Created by Niykee Moore on 05.04.2025.
//

import Foundation

enum CartState {
    case initial
    case loading
    case failed(Error)
    case data([CartItem])
}
