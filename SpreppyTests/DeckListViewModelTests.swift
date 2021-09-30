//
//  DeckListViewModelTests.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 9/25/21.
//

import Combine
import Foundation
@testable import Spreppy
import XCTest

class DeckListViewModelDelegateSpy: DeckListViewModelDelegate {
    var state = DeckListState()

    func update(state: DeckListState) {
        self.state = state
    }
}

class DeskListViewModelTests: XCTestCase {
    private var delegate: DeckListViewModelDelegateSpy!
    private var repos: RepositorySpies!
    private var subject: DeckListViewModel!

    override func setUp() {
        delegate = DeckListViewModelDelegateSpy()
        repos = RepositorySpies()
    }

    override func tearDown() {
        delegate = nil
        repos = nil
        subject = nil
    }

    func testHandleViewDidLoad() {
        let decks = [
            DeckModel(uuid: UUID(), title: "Test 1"),
            DeckModel(uuid: UUID(), title: "Test 2"),
            DeckModel(uuid: UUID(), title: "Test 3"),
        ]

        repos.deckRepoSpy.setDeckList(decks)

        subject = DeckListViewModel(repos: repos, delegate: delegate)
        subject.handle(.viewDidLoad)
        XCTAssertEqual(delegate.state.decks, decks)
    }

    func testHandleDoneTapped() {
        subject = DeckListViewModel(state: DeckListState(isEditing: true), repos: repos, delegate: delegate)
        subject.handle(.doneTapped)
        XCTAssertFalse(delegate.state.isEditing)
    }

    func testHandleEditTapped() {
        subject = DeckListViewModel(state: DeckListState(isEditing: false), repos: repos, delegate: delegate)
        subject.handle(.editTapped)
        XCTAssertTrue(delegate.state.isEditing)
    }
}
