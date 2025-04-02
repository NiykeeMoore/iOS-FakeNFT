//
//  CartAssembly.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import UIKit

final class CartAssembly {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }

    func build() -> UIViewController {
        let cartService = CartServiceImpl(networkClient: servicesAssembly.networkClient)
        let viewModel = CartViewModelImpl(cartService: cartService)
        let viewController = CartViewController(viewModel: viewModel)
        
        return viewController
    }
}
