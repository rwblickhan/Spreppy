//
//  Coordinator.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
import UIKit

enum NavigationTarget: Equatable {
    case deckInfo(deckID: UUID)
    case deckList
    case deckStudy(deckID: UUID)
}

protocol Coordinator {
    func navigate(to target: NavigationTarget)
}

struct MainCoordinator: Coordinator {
    private let repos = CoreDataRepositories(persistentContainer: AppDelegate.sharedAppDelegate.persistentContainer)
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func navigate(to target: NavigationTarget) {
        let viewController: UIViewController
        switch target {
        case .deckList:
            viewController = DeckListViewController(coordinator: self, repos: repos)
        case let .deckStudy(deckID):
            viewController = DeckStudyViewController(
                deckID: deckID,
                coordinator: self,
                repos: repos)
        case let .deckInfo(deckID):
            viewController = DeckInfoViewController(
                deckID: deckID,
                coordinator: self,
                repos: repos)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
