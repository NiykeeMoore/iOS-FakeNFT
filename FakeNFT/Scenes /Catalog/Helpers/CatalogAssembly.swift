//
//  CatalogAssembly.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 07.04.2025.
//

import UIKit

final class CatalogAssembly {
    
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    func build() -> UIViewController {
        let viewModel = CatalogViewModel(netWorkClient: DefaultNetworkClient())
        let viewController = CatalogViewController(viewModel: viewModel, servicesAssembly: servicesAssembly)
        
        return viewController
    }
}
