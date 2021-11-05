//
//  CoordinatorSpy.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
import UIKit
@testable import Spreppy

class CoordinatorSpy: Coordinator {
    let navigationController = UINavigationController()
    private(set) var targets = [NavigationTarget]()
    private(set) var didDismiss = false

    func navigate(to target: NavigationTarget) {
        targets.append(target)
    }
    
    func dismiss() {
        didDismiss = true
    }

    func reset() {
        targets.removeAll()
        didDismiss = false
    }
}
