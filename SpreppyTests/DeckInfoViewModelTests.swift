//
//  DeckInfoViewModelTests.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/13/21.
//

import Combine
import Foundation
@testable import Spreppy
import XCTest

class DeckInfoViewModelDelegateSpy: DeckInfoViewModelDelegate {
    var state = DeckInfoState()

    func update(state: DeckInfoState) {
        self.state = state
    }
}

class DeckInfoViewModelTests: XCTestCase {
    private var delegate: DeckInfoViewModelDelegateSpy!
    private var coordinator: CoordinatorSpy!
    private var repos: RepositorySpies!
    private var subject: DeckInfoViewModel!

    private let testUUID = UUID()

    override func setUp() {
        delegate = DeckInfoViewModelDelegateSpy()
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
        let decks = [DeckModel(uuid: testUUID, title: "Test Title")]
        repos.deckRepoSpy.setDeckList(decks)
        subject = DeckInfoViewModel(deckID: testUUID, coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.viewDidLoad)
        XCTAssertEqual(delegate.state.title, "Test Title Settings")
    }
}
