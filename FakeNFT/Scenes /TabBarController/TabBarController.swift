import UIKit

final class TabBarController: UITabBarController {
    
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let cartTabBarItem: UITabBarItem = {
        let image = UIImage(named: "tabIconCart")
        let item = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: ""),
            image: image,
            tag: 2
        )
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        let cartAssembly = CartAssembly(servicesAssembly: servicesAssembly)
        let cartController = cartAssembly.build()
        cartController.tabBarItem = cartTabBarItem
        
        viewControllers = [catalogController, cartController]
        
        tabBar.unselectedItemTintColor = UIColor(named: "appBlackDynamic")
    }
}
