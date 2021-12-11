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
    case addCard(deckID: UUID)
    case confirmCancelAlert(onConfirm: () -> Void)
    case confirmDeleteAlert(onConfirm: () -> Void)
    case createDeck
    case deckInfo(deckID: UUID)
    case deckList
    case deckStudy(deckID: UUID)
    case settings

    var type: NavigationTargetType {
        switch self {
        case .addCard, .createDeck:
            return .modal
        case .confirmCancelAlert, .confirmDeleteAlert:
            return .alert
        case .deckInfo, .deckList, .deckStudy, .settings:
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
        case (.settings, .settings): return true
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
    private let repos = CoreDataRepositories(persistentContainer: AppDelegate.sharedAppDelegate.persistentContainer)

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
        case let .addCard(deckID):
            viewController = AddCardViewController(deckID: deckID, coordinator: coordinator, repos: repos)
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
            viewController = CreateDeckViewController(
                coordinator: coordinator,
                repos: repos)
        case .deckList:
            viewController = DeckListViewController(coordinator: coordinator, repos: repos)
        case let .deckStudy(deckID):
            viewController = DeckStudyViewController(
                deckID: deckID,
                coordinator: coordinator,
                repos: repos)
        case let .deckInfo(deckID):
            viewController = DeckInfoViewController(
                deckID: deckID,
                coordinator: coordinator,
                repos: repos)
        case let .settings:
            viewController = SettingsViewController(
                coordinator: coordinator,
                repos: repos)
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
