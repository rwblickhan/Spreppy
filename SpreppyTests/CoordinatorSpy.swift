//
//  CoordinatorSpy.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
@testable import Spreppy

class CoordinatorSpy: Coordinator {
    private(set) var targets = [NavigationTarget]()

    func navigate(to target: NavigationTarget) {
        targets.append(target)
    }

    func reset() {
        targets.removeAll()
    }
}
