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
        XCTAssertEqual(coordinator.targets.last, .createDeck)
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

        guard case let .confirmDeleteAlert(onConfirm) = coordinator.targets.last else { XCTFail(); return }
        onConfirm()
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
    
    func testHandleSettingsTapped() {
        subject = DeckListViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.settingsTapped)
        guard case .settings = coordinator.targets.last else { XCTFail(); return }
    }
}
