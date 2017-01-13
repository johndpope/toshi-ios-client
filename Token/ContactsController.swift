import UIKit
import SweetUIKit

open class ContactsController: SweetTableController {

    public init() {
        super.init()

        self.tabBarItem = UITabBarItem(title: "Contacts", image: #imageLiteral(resourceName: "Contacts"), tag: 1)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

    }
}
