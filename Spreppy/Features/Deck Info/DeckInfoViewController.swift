//
//  DeckInfoViewController.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/13/21.
//

import Foundation
import UIKit

class DeckInfoViewController: UIViewController, DeckInfoViewModelDelegate {
    private var viewModel: DeckInfoViewModel!

    init(deck: RealmDeck, coordinator: Coordinator) {
        super.init(nibName: nil, bundle: nil)
        viewModel = DeckInfoViewModel(
            deck: deck,
            coordinator: coordinator,
            delegate: self)
    }

    // MARK: UIViewController

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder:) is unimplemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        viewModel.handle(.viewDidLoad)
    }

    // MARK: DeckStudyViewModelDelegate

    func update(state: DeckInfoState) {
        title = state.title
    }
}
