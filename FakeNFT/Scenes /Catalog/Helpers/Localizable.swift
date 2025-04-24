//
//  Localizable.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 15.04.2025.
//

import Foundation

enum Localizable {
    enum Sorting {
        static let byName = NSLocalizedString(
            "Sorting.byName",
            value: "By Name",
            comment: "Sort by name option"
        )
        static let byQuantity = NSLocalizedString(
            "Sorting.byQuantity",
            value: "By Quantity",
            comment: "Sort by quantity option"
        )
        static let cancel = NSLocalizedString(
            "Sorting.cancel",
            value: "Cancel",
            comment: "Cancel sorting action"
        )
        static let alertTitle = NSLocalizedString(
            "Sorting.alertTitle",
            value: "Sorting",
            comment: "Title for sorting action sheet"
        )
    }
}
