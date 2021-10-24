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
    private var coordinator: CoordinatorSpy!
    private var repos: RepositorySpies!
    private var subject: DeckListViewModel!

    override func setUp() {
        delegate = DeckListViewModelDelegateSpy()
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
        let decks = [
            DeckModel(uuid: UUID(), title: "Test 1"),
            DeckModel(uuid: UUID(), title: "Test 2"),
            DeckModel(uuid: UUID(), title: "Test 3"),
        ]

        repos.deckRepoSpy.setDeckList(decks)

        subject = DeckListViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.viewDidLoad)
        XCTAssertEqual(delegate.state.decks, decks)
    }

    func testHandleAddTapped() {
        subject = DeckListViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        // Handle `.viewDidLoad` to set up state subscription
        subject.handle(.viewDidLoad)
        subject.handle(.addTapped)
        subject.handle(.addTapped)

        let decks = repos.deckRepoSpy.modelList.value
        XCTAssertEqual("Blah blah blah", decks.first?.title)
        XCTAssertEqual(0, decks.first?.rank)
        XCTAssertEqual("Blah blah blah", decks.last?.title)
        XCTAssertEqual(1, decks.last?.rank)
    }

    func testHandleDoneTapped() {
        subject = DeckListViewModel(
            state: DeckListState(isEditing: true),
            coordinator: coordinator,
            repos: repos,
            delegate: delegate)
        subject.handle(.doneTapped)
        XCTAssertFalse(delegate.state.isEditing)
    }

    func testHandleEditTapped() {
        subject = DeckListViewModel(
            state: DeckListState(isEditing: false),
            coordinator: coordinator,
            repos: repos,
            delegate: delegate)
        subject.handle(.editTapped)
        XCTAssertTrue(delegate.state.isEditing)
    }

    func testHandleDeleteTapped() {
        let testUUID = UUID()
        let decks = [DeckModel(uuid: testUUID)]
        subject = DeckListViewModel(
            state: DeckListState(decks: decks, isEditing: true),
            coordinator: coordinator,
            repos: repos,
            delegate: delegate)
        subject.handle(.deleteTapped(0))
        XCTAssertTrue(repos.deckRepoSpy.modelList.value.isEmpty)
    }

    func testHandleDeckSelected() {
        let testUUID = UUID()
        let decks = [DeckModel(uuid: testUUID)]
        subject = DeckListViewModel(
            state: DeckListState(decks: decks, isEditing: false),
            coordinator: coordinator,
            repos: repos,
            delegate: delegate)
        subject.handle(.deckSelected(0))
        XCTAssertEqual(coordinator.targets.last, .deckStudy(deckID: testUUID))
    }

    func testHandleDeckInfoSelected() {
        let testUUID = UUID()
        let decks = [DeckModel(uuid: testUUID)]
        subject = DeckListViewModel(
            state: DeckListState(decks: decks, isEditing: false),
            coordinator: coordinator,
            repos: repos,
            delegate: delegate)
        subject.handle(.deckInfoSelected(0))
        XCTAssertEqual(coordinator.targets.last, .deckInfo(deckID: testUUID))
    }
}
