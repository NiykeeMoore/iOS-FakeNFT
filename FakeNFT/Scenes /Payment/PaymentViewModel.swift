//
//  PaymentViewModel.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

enum PaymentState {
    case initial, loading, loaded([PaymentMethod]), error(Error)
}

protocol PaymentViewModelProtocol {
    var state: PaymentState { get }
    var paymentMethods: [PaymentMethod] { get }
    var onStateChange: ((PaymentState) -> Void)? { get set }
    var onPaymentMethodsChange: (() -> Void)? { get set }
    var onPaymentProcessing: (() -> Void)? { get set }
    var onPaymentSuccess: (() -> Void)? { get set }
    var onPaymentFailed: ((ErrorModel) -> Void)? { get set }
    
    func loadPaymentMethods()
    func selectPaymentMethod(index: Int)
    func performPayment()
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
    var onPaymentProcessing: (() -> Void)?
    var onPaymentSuccess: (() -> Void)?
    var onPaymentFailed: ((ErrorModel) -> Void)?
    
    private let paymentService: PaymentServiceProtocol
    private let cartService: CartService
    private var selectedPaymentMethodId: String?
    
    init(paymentService: PaymentServiceProtocol, cartService: CartService) {
        self.paymentService = paymentService
        self.cartService = cartService
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
                    self.state = .loaded(methods)
                case .failure(let error):
                    _ = self.makeErrorModel(error: error)
                    self.state = .error(error)
                }
            }
        }
    }
    
    func selectPaymentMethod(index: Int) {
        guard index >= 0 && index < paymentMethods.count else {
            selectedPaymentMethodId = nil
            print("Ошибка: Неверный индекс для выбора способа оплаты")
            return
        }
        selectedPaymentMethodId = paymentMethods[index].id
    }
    
    func performPayment() {
        guard let currencyId = selectedPaymentMethodId else {
            let errorModel = ErrorModel(
                message: "",
                actionText: NSLocalizedString("payment_error_noMethodSelected", comment: "")
            ) {
                
            }
            
            onPaymentFailed?(errorModel)
            return
        }
        
        onPaymentProcessing?()
        
        paymentService.performPayment(currencyId: currencyId) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let paymentResult):
                if paymentResult.success {
                    self.cartService.updateOrder(with: []) { result in
                        switch result {
                        case .success:
                            print("Корзина очищена после оплаты")
                        case .failure(let error):
                            print("Не удалось очистить корзину после оплаты: \(error)")
                        }
                    }
                    self.onPaymentSuccess?()
                } else {
                    let errorModel = ErrorModel(
                        message: "",
                        actionText: NSLocalizedString("payment_error_serverRejected", comment: "")
                    ) {
                        
                    }
                    self.onPaymentFailed?(errorModel)
                }
                
            case .failure(let error):
                let errorModel = self.makeErrorModel(error: error)
                self.onPaymentFailed?(errorModel)
            }
        }
    }
    
    private func makeErrorModel(error: Error) -> ErrorModel {
        let message: String
        if let networkError = error as? NetworkClientError {
            switch networkError {
            case .httpStatusCode(let code):
                message = String(format: NSLocalizedString("payment_error_httpError", comment: ""), code)
                
            case .parsingError:
                message = NSLocalizedString("payment_error_parsingError", comment: "")
                
            case .urlRequestError(let underlyingError):
                message = String(
                    format: NSLocalizedString("payment_error_networkError", comment: ""),
                    underlyingError.localizedDescription
                )
                
            case .urlSessionError:
                message = NSLocalizedString("payment_error_urlSessionError", comment: "")
            }
        } else {
            message = error.localizedDescription
        }
        
        return ErrorModel(
            message: message,
            actionText: NSLocalizedString("payment_error_repeat", comment: "")
        ) {
            
        }
    }
}
