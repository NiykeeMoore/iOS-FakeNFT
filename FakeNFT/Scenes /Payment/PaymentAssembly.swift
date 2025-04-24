//
//  PaymentAssembly.swift
//  FakeNFT
//
//  Created by Niykee Moore on 19.04.2025.
//

import UIKit

final class PaymentAssembly {
    private let servicesAssembler: ServicesAssembly
    
    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }
    
    func build() -> UIViewController {
        let networkClient = servicesAssembler.networkClient
        let paymentService = PaymentService(networkClient: networkClient)
        let cartService = servicesAssembler.cartService
        let viewModel = PaymentViewModel(paymentService: paymentService, cartService: cartService)
        let viewController = PaymentMethodViewController(viewModel: viewModel)
        return viewController
    }
}
