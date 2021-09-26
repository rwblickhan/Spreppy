//
//  DeskListViewModelTests.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 9/25/21.
//

@testable import Spreppy
import Foundation
import Combine
import XCTest

class DeckListViewModelDelegateSpy: DeckListViewModelDelegate {
    var state = DeckListState()
    
    func update(state: DeckListState) {
        self.state = state
    }
}

class DeckRepositorySpy: DeckRepository {
    private let deckList = CurrentValueSubject<Array<DeckModel>, Never>([])
    func fetchDeckList() -> AnyPublisher<Array<DeckModel>, Never> {
        deckList.eraseToAnyPublisher()
    }
    
    func create(_ deckModel: DeckModel) {
        var decks = deckList.value
        decks.append(deckModel)
        deckList.send(decks)
    }
    
    func setDeckList(_ decks: [DeckModel]) {
        deckList.send(decks)
    }
}

class DeskListViewModelTests: XCTestCase {
    private var delegate: DeckListViewModelDelegateSpy!
    private var repository: DeckRepositorySpy!
    private var subject: DeckListViewModel!
    
    override func setUp() {
        delegate = DeckListViewModelDelegateSpy()
        repository = DeckRepositorySpy()
    }
    
    override func tearDown() {
        delegate = nil
        repository = nil
        subject = nil
    }
    
    func testHandleViewDidLoad() {
        let decks = [
            DeckModel(uuid: UUID(), title: "Test 1"),
            DeckModel(uuid: UUID(), title: "Test 2"),
            DeckModel(uuid: UUID(), title: "Test 3"),
        ]
        repository.setDeckList(decks)
        
        subject = DeckListViewModel(repository: repository, delegate: delegate)
        subject.handle(.viewDidLoad)
        XCTAssertEqual(delegate.state.snapshot.itemIdentifiers(inSection: 0), decks)
    }
    
    func testHandleDoneTapped() {
        subject = DeckListViewModel(state: DeckListState(isEditing: true), repository: repository, delegate: delegate)
        subject.handle(.doneTapped)
        XCTAssertFalse(delegate.state.isEditing)
    }
    
    func testHandleEditTapped() {
        subject = DeckListViewModel(state: DeckListState(isEditing: false), repository: repository, delegate: delegate)
        subject.handle(.editTapped)
        XCTAssertTrue(delegate.state.isEditing)
    }
}
