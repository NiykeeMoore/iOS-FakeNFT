//
//  PaymentMethod.swift
//  FakeNFT
//
//  Created by Niykee Moore on 19.04.2025.
//

import Foundation

import UIKit

struct PaymentMethod: Decodable, Identifiable {
    let id: String
    let name: String
    let title: String
    let image: String
}
