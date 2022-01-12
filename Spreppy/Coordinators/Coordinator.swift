//
//  Coordinator.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
import UIKit

enum NavigationTargetType {
    case alert
    case navigationStack
    case modal
}

enum NavigationTarget: Equatable {
    case addCard(deck: RealmDeck)
    case confirmCancelAlert(onConfirm: () -> Void)
    case confirmDeleteAlert(onConfirm: () -> Void)
    case createDeck
    case deckInfo(deck: RealmDeck)
    case deckList
    case deckStudy(deck: RealmDeck)

    var type: NavigationTargetType {
        switch self {
        case .addCard, .createDeck:
            return .modal
        case .confirmCancelAlert, .confirmDeleteAlert:
            return .alert
        case .deckInfo, .deckList, .deckStudy:
            return .navigationStack
        }
    }

    static func == (lhs: NavigationTarget, rhs: NavigationTarget) -> Bool {
        switch (lhs, rhs) {
        case let (.addCard(deckA), .addCard(deckB)): return deckA == deckB
        case (.confirmCancelAlert, .confirmCancelAlert): return true
        case (.confirmDeleteAlert, .confirmDeleteAlert): return true
        case (.createDeck, .createDeck): return true
        case let (.deckInfo(deckA), .deckInfo(deckB)): return deckA == deckB
        case (.deckList, .deckList): return true
        case let (.deckStudy(deckA), .deckStudy(deckB)): return deckA == deckB
        case (_, _): return false
        }
    }
}

protocol Coordinator {
    var navigationController: UINavigationController { get }
    func navigate(to target: NavigationTarget)
    func dismiss()
}

class MainCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
    }

    func navigate(to target: NavigationTarget) {
        let coordinator: Coordinator
        switch target.type {
        case .modal: coordinator = MainCoordinator(navigationController: UINavigationController())
        case .alert, .navigationStack: coordinator = self
        }

        let viewController: UIViewController
        switch target {
        case let .addCard(deck):
            viewController = AddCardViewController(deck: deck, coordinator: coordinator)
        case let .confirmCancelAlert(onConfirm):
            let alert = UIAlertController(
                title: "Are you sure?",
                message: "You entered some information; are you sure you want to cancel?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in onConfirm() }))
            viewController = alert
        case let .confirmDeleteAlert(onConfirm):
            let alert = UIAlertController(
                title: "Are you sure?",
                message: "Deleting a deck can't be undone.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in onConfirm() }))
            viewController = alert
        case .createDeck:
            viewController = CreateDeckViewController(coordinator: coordinator)
        case .deckList:
            viewController = DeckListViewController(coordinator: coordinator)
        case let .deckStudy(deck):
            viewController = DeckStudyViewController(deck: deck, coordinator: coordinator)
        case let .deckInfo(deck):
            viewController = DeckInfoViewController(deck: deck, coordinator: coordinator)
        }

        switch target.type {
        case .alert:
            navigationController.present(viewController, animated: true, completion: nil)
        case .modal:
            coordinator.navigationController.viewControllers = [viewController]
            navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        case .navigationStack:
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func dismiss() {
        if navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
}
