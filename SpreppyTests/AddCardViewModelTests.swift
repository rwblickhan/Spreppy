//
//  AddCardViewModelTests.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 11/4/21.
//

import Combine
import Foundation
@testable import Spreppy
import XCTest

class AddCardViewModelDelegateSpy: AddCardViewModelDelegate {
    var state = AddCardState()

    func update(state: AddCardState) {
        self.state = state
    }
}

class AddCardViewModelTests: XCTestCase {
    private var delegate: AddCardViewModelDelegateSpy!
    private var coordinator: CoordinatorSpy!
    private var repos: RepositorySpies!
    private var subject: AddCardViewModel!

    private let testUUID = UUID()

    override func setUp() {
        delegate = AddCardViewModelDelegateSpy()
        coordinator = CoordinatorSpy()
        repos = RepositorySpies()
    }

    override func tearDown() {
        delegate = nil
        coordinator = nil
        repos = nil
        subject = nil
    }

    func testHandleCancelTapped() {
        subject = AddCardViewModel(deckID: testUUID, coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.cancelTapped)
        XCTAssertTrue(coordinator.didDismiss)
    }

    func testHandleSaveTapped() {
        subject = AddCardViewModel(deckID: testUUID, coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.saveTapped(frontText: "Front Text", backText: "Back Text"))
        let cards = repos.cardRepoSpy.modelList.value
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.deckUUID, testUUID)
        XCTAssertEqual(cards.first?.frontText, "Front Text")
        XCTAssertEqual(cards.first?.backText, "Back Text")
        XCTAssertTrue(coordinator.didDismiss)
    }
}
