//
//  CreateDeckViewModelTests.swift
//  SpreppyTests
//
//  Created by Sherry Yuan on 11/27/21.
//

import Foundation
@testable import Spreppy
import XCTest

class CreateDeckViewModelDelegateSpy: CreateDeckViewModelDelegate {
    var state = CreateDeckState()

    func update(state: CreateDeckState) {
        self.state = state
    }
}

class CreateDeckViewModelTests: XCTestCase {
    private var delegate: CreateDeckViewModelDelegateSpy!
    private var coordinator: CoordinatorSpy!
    private var repos: RepositorySpies!
    private var subject: CreateDeckViewModel!

    private let testUUID = UUID()

    override func setUp() {
        delegate = CreateDeckViewModelDelegateSpy()
        coordinator = CoordinatorSpy()
        repos = RepositorySpies()
    }

    override func tearDown() {
        delegate = nil
        coordinator = nil
        repos = nil
        subject = nil
    }

    func testHandleTitleChanged() {
        subject = CreateDeckViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.titleChanged("Deck Title"))
        XCTAssertEqual(delegate.state.title, "Deck Title")
    }

    func testHandleCancelTappedNoContent() {
        subject = CreateDeckViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.cancelTapped)
        XCTAssertTrue(coordinator.didDismiss)
    }

    func testHandleCancelTappedWithContent() {
        subject = CreateDeckViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.titleChanged("Deck Title"))
        subject.handle(.cancelTapped)

        XCTAssertFalse(coordinator.didDismiss)
        guard case let .confirmCancelAlert(onConfirm) = coordinator.targets.last else { XCTFail(); return }
        onConfirm()
        XCTAssertTrue(coordinator.didDismiss)
    }

    func testHandleSummaryChanged() {
        subject = CreateDeckViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.summaryChanged("Summary"))
        XCTAssertEqual(delegate.state.summary, "Summary")
    }

    func testHandleSaveTapped() {
        subject = CreateDeckViewModel(coordinator: coordinator, repos: repos, delegate: delegate)
        subject.handle(.saveTapped(title: "Deck title", summary: "Summary"))
        let decks = repos.deckRepoSpy.modelList.value
        XCTAssertEqual(decks.count, 1)
        XCTAssertEqual(decks.first?.title, "Deck title")
        XCTAssertEqual(decks.first?.summary, "Summary")
        XCTAssertTrue(coordinator.didDismiss)
    }
}
