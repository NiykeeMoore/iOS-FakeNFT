//
//  CartViewModel.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

protocol CartViewModel {
    var onItemsUpdate: (() -> Void)? { get set }
    var onTotalUpdate: ((Int, String) -> Void)? { get set }
    var onLoadingStateChange: ((Bool) -> Void)? { get set }
    var onError: ((ErrorModel) -> Void)? { get set }
    var didSortButtonTapped: (() -> Void)? { get set }
    var onSortStateDidChanged: ((CartSortType) -> Void)? { get }
    
    func numberOfItems() -> Int
    func item(at indexPath: IndexPath) -> CartItem?
    func viewDidLoad()
    func retryLoad()
}

final class CartViewModelImpl: CartViewModel {
    var onItemsUpdate: (() -> Void)?
    var onTotalUpdate: ((Int, String) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((ErrorModel) -> Void)?
    var didSortButtonTapped: (() -> Void)?
    var onSortStateDidChanged: ((CartSortType) -> Void)?
    
    private let cartService: CartService
    private var cartItems: [CartItem] = [] {
        didSet {
            onItemsUpdate?()
            calculateTotal()
        }
    }
    
    private var state = CartState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    private var sortState = CartSortType.nameDescending {
        didSet {
            sortStateDidChanged()
        }
    }
    
    init(cartService: CartService) {
        self.cartService = cartService
        
        onSortStateDidChanged = { [weak self] sortType in
            guard let self else {
                return
            }
            self.sortState = sortType
        }
    }
    
    // MARK: - CartViewModel Protocol
    
    func viewDidLoad() {
        state = .loading
    }
    
    func retryLoad() {
        state = .loading
    }
    
    func numberOfItems() -> Int {
        return cartItems.count
    }
    
    func item(at indexPath: IndexPath) -> CartItem? {
        guard indexPath.row < cartItems.count else {
            return nil
        }
        return cartItems[indexPath.row]
    }
    
    // MARK: - Private Methods
    
    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("Невозможно перейти в начальное состояние")
            
        case .loading:
            onLoadingStateChange?(true)
            loadCartData()
            
        case .data(let items):
            onLoadingStateChange?(false)
            cartItems = items
            sortState = .nameDescending
            
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            onLoadingStateChange?(false)
            onError?(errorModel)
        }
    }
    
    private func loadCartData() {
        cartService.loadOrder { [weak self] result in
            guard let self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.state = .data(items)
                case .failure(let error):
                    self.state = .failed(error)
                }
            }
        }
    }
    
    private func calculateTotal() {
        let totalCount = cartItems.count
        let totalPrice = cartItems.reduce(0.0) { $0 + $1.price }
        let formattedPrice = String(format: "%.2f ETH", totalPrice)
        
        onTotalUpdate?(totalCount, formattedPrice)
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
            self.retryLoad()
        }
    }
    
    private func sortStateDidChanged() {
        switch sortState {
        case .priceDescending:
            sortItemsByPrice()
            
        case .nameDescending:
            sortItemsByName()
            
        case .raitingDescending:
            sortItemsByRating()
            
        case .cancel:
            break
        }
    }
    
    private func sortItemsByName() {
        DispatchQueue.global().async { [weak self] in
            guard let self else {
                return
            }
            var sortedItems = self.cartItems
            sortedItems.sort { $0.name < $1.name }
            
            DispatchQueue.main.async {
                self.cartItems = sortedItems
            }
        }
    }
    
    private func sortItemsByPrice() {
        DispatchQueue.global().async { [weak self] in
            guard let self else {
                return
            }
            var sortedItems = self.cartItems
            sortedItems.sort { $0.price > $1.price }
            
            DispatchQueue.main.async {
                self.cartItems = sortedItems
            }
        }
    }
    
    private func sortItemsByRating() {
        DispatchQueue.global().async { [weak self] in
            guard let self else {
                return
            }
            var sortedItems = self.cartItems
            sortedItems.sort { $0.rating > $1.rating }
            
            DispatchQueue.main.async {
                self.cartItems = sortedItems
            }
        }
    }
}
