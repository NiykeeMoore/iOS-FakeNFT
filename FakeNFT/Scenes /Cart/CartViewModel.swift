//
//  CartViewModel.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

protocol CartView: AnyObject, ErrorView, LoadingView {
    func displayCartItems(_ items: [CartItem])
    func updateTotal(count: Int, price: String)
}

protocol CartViewModel {
    func viewDidLoad()
}

enum CartState {
    case initial
    case loading
    case failed(Error)
    case data([CartItem])
}

final class CartViewModelImpl: CartViewModel {
    // MARK: - Properties
    
    weak var view: CartView?
    private let cartService: CartService
    private var cartItems: [CartItem] = [] {
        didSet {
            calculateTotal()
        }
    }
    
    private var state = CartState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    // MARK: - Init
    
    init(cartService: CartService) {
        self.cartService = cartService
    }
    
    // MARK: - CartViewModel
    
    func viewDidLoad() {
        state = .loading
    }
    
    // MARK: - Private Methods
    
    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("Невозможно перейти в начальное состояние")
        case .loading:
            view?.showLoading()
            loadCartData()
        case .data(let items):
            view?.hideLoading()
            self.cartItems = items
            view?.displayCartItems(items)
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }
    
    private func loadCartData() {
        cartService.loadOrder { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let items):
                self.state = .data(items)
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }
    
    private func calculateTotal() {
        let totalCount = cartItems.count
        let totalPrice = cartItems.reduce(0.0) { $0 + $1.price }
        
        let formattedPrice = String(format: "%.2f ETH", totalPrice)
        
        view?.updateTotal(count: totalCount, price: formattedPrice)
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = NSLocalizedString("Error.network", comment: "")
        default:
            message = NSLocalizedString("Error.unknown", comment: "")
        }
        
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            guard let self else {
                return
            }
            self.state = .loading
        }
    }
}
