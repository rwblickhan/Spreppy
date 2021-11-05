//
//  Coordinator.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
import UIKit

enum NavigationTargetType {
    case navigationStack
    case modal
}

enum NavigationTarget: Equatable {
    case addCard(deckID: UUID)
    case deckInfo(deckID: UUID)
    case deckList
    case deckStudy(deckID: UUID)
    
    var type: NavigationTargetType {
        switch self {
        case .addCard:
            return .modal
        case .deckInfo, .deckList, .deckStudy:
            return .navigationStack
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
        case .navigationStack: coordinator = self
        }
        
        let viewController: UIViewController
        switch target {
        case let .addCard(deckID):
            viewController = AddCardViewController(deckID: deckID, coordinator: coordinator, repos: repos)
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
        }
        
        switch target.type {
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
