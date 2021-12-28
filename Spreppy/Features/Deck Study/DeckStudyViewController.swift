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
    private var state = DeckStudyState()

    private let cardStack = SwipeCardStack()
    private lazy var infoBarButton = UIBarButtonItem(
        image: UIImage(systemName: "gear"),
        style: .plain,
        target: self,
        action: #selector(didTapInfo))
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

        navigationItem.setRightBarButtonItems([addBarButton, infoBarButton], animated: false)
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
        let oldState = self.state
        self.state = state
        title = state.deck?.title

        if oldState != state {
            cardStack.reloadData()
        }
    }

    // MARK: SwipeCardStackDelegate

    func cardStack(_: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        viewModel.handle(.didSwipeCard(index: index, direction: direction))
    }

    // MARK: SwipeCardStackDataSource

    func cardStack(_: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        guard let cardModel = viewModel.state.card(at: index) else { return SwipeCard() }
        return makeSwipeCard(for: cardModel)
    }

    func numberOfCards(in _: SwipeCardStack) -> Int {
        viewModel.state.numberOfCards
    }

    // MARK: Helpers

    @objc private func didTapInfo() {
        viewModel.handle(.infoTapped)
    }

    @objc private func didTapAdd() {
        viewModel.handle(.addTapped)
    }

    // MARK: View Factories

    private func makeSwipeCard(for cardModel: CardModel) -> SwipeCard {
        let singleCardView = SingleCardView()
        singleCardView.configure(with: cardModel)

        let swipeCard = SwipeCard()
        swipeCard.swipeDirections = [.left, .right]
        swipeCard.content = singleCardView
        swipeCard.setOverlays([.left: makeOverlay(of: .red), .right: makeOverlay(of: .green)])
        return swipeCard
    }

    private func makeOverlay(of color: UIColor) -> UIView {
        let overlay = UIView()
        overlay.backgroundColor = color
        overlay.layer.cornerRadius = 15
        overlay.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return overlay
    }
}
