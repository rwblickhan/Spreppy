//
//  DeckStudyViewController.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation
import Shuffle
import UIKit

class DeckStudyViewController: UIViewController,
    DeckStudyViewModelDelegate,
    SwipeCardStackDataSource,
    SwipeCardStackDelegate {
    private var viewModel: DeckStudyViewModel!

    private let cardImages = [
        UIImage(named: "cardImage1"),
        UIImage(named: "cardImage2"),
        UIImage(named: "cardImage3"),
    ]

    private let cardStack = SwipeCardStack()
    private lazy var addBarButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(didTapAdd))

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

        cardStack.dataSource = self
        cardStack.delegate = self

        cardStack.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Navigation Bar

        navigationItem.setRightBarButton(addBarButton, animated: false)
        navigationItem.largeTitleDisplayMode = .never

        // MARK: View Hierarchy

        view.addSubview(cardStack)

        // MARK: Layout

        cardStack.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: cardStack.trailingAnchor, multiplier: 1)
            .isActive = true
        cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        cardStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func viewDidLoad() {
        viewModel.handle(.viewDidLoad)
    }

    // MARK: DeckStudyViewModelDelegate

    func update(state: DeckStudyState) {
        title = state.deck?.title
        cardStack.reloadData()
    }

    // MARK: SwipeCardStackDelegate

    func cardStack(_: SwipeCardStack, didSelectCardAt _: Int) {
        // TODO:
    }

    func cardStack(_: SwipeCardStack, didSwipeCardAt _: Int, with _: SwipeDirection) {
        // TODO:
    }

    // MARK: SwipeCardStackDataSource

    func cardStack(_: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .right]
        let label = UILabel()
        label.text = viewModel.state.deck?.cardUUIDs[index].uuidString ?? ""
        card.content = label
        card.content?.backgroundColor = .white

        let leftOverlay = UIView()
        leftOverlay.backgroundColor = .red
        let rightOverlay = UIView()
        rightOverlay.backgroundColor = .green
        card.setOverlays([.left: leftOverlay, .right: rightOverlay])

        return card
    }

    func numberOfCards(in _: SwipeCardStack) -> Int {
        viewModel.state.deck?.cardUUIDs.count ?? 0
    }

    // MARK: Helpers

    @objc private func didTapAdd() {
        viewModel.handle(.addTapped)
    }
}
