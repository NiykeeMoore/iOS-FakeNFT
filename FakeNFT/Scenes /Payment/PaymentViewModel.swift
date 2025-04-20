//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

enum PaymentState {
    case initial, loading, loaded, error(Error)
}

protocol PaymentViewModelProtocol {
    var state: PaymentState { get }
    var paymentMethods: [PaymentMethod] { get }
    var onStateChange: ((PaymentState) -> Void)? { get set }
    var onPaymentMethodsChange: (() -> Void)? { get set }
    
    func loadPaymentMethods()
}

final class PaymentViewModel: PaymentViewModelProtocol {
    
    private(set) var state: PaymentState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    private(set) var paymentMethods: [PaymentMethod] = [] {
        didSet {
            onPaymentMethodsChange?()
        }
    }
    
    var onStateChange: ((PaymentState) -> Void)?
    var onPaymentMethodsChange: (() -> Void)?
    
    private let paymentService: PaymentServiceProtocol
    
    init(paymentService: PaymentServiceProtocol) {
        self.paymentService = paymentService
    }
    
    func loadPaymentMethods() {
        switch state {
        case .loading:
            return
            
        default:
            state = .loading
            
            paymentService.loadPaymentMethods { [weak self] result in
                guard let self else {
                    return
                }
                
                switch result {
                case .success(let methods):
                    self.paymentMethods = methods
                    self.state = .loaded
                case .failure(let error):
                    self.state = .error(error)
                }
            }
        }
    }
}
