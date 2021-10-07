//
//  DeckStudyViewController.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
import UIKit

class DeckStudyViewController: UIViewController, DeckStudyViewModelDelegate {
    private var viewModel: DeckStudyViewModel!
    
    init(deckID: UUID, coordinator: Coordinator, repos: Repositories) {
        super.init(nibName: nil, bundle: nil)
        viewModel = DeckStudyViewModel(
            deckID: deckID,
            coordinator: coordinator,
            repos: repos,
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
    
    func update(state: DeckStudyState) {
        title = state.title
    }
}
