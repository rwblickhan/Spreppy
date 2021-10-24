//
//  DeckStudyViewModelTests.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 10/6/21.
//

import Combine
import Foundation
@testable import Spreppy
import XCTest

class DeckStudyViewModelDelegateSpy: DeckStudyViewModelDelegate {
    var state = DeckStudyState()

    func update(state: DeckStudyState) {
        self.state = state
    }
}

class DeskStudyViewModelTests: XCTestCase {
    private var delegate: DeckStudyViewModelDelegateSpy!
    private var coordinator: CoordinatorSpy!
    private var repos: RepositorySpies!
    private var subject: DeckStudyViewModel!

    private let testUUID = UUID()

    override func setUp() {
        delegate = DeckStudyViewModelDelegateSpy()
        coordinator = CoordinatorSpy()
        repos = RepositorySpies()
    }

    override func tearDown() {
        delegate = nil
        coordinator = nil
        repos = nil
        subject = nil
    }

    func testHandleViewDidLoad() {
        let deck = DeckModel(uuid: testUUID)
        repos.deckRepoSpy.setDeckList([deck])
        subject = DeckStudyViewModel(deckID: testUUID, coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.viewDidLoad)
        XCTAssertEqual(delegate.state.deck, deck)
    }

    func testHandleAddTapped() {
        subject = DeckStudyViewModel(deckID: testUUID, coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.addTapped)
        let cards = repos.cardRepoSpy.cardList.value
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.deckUUID, testUUID)
    }
}
