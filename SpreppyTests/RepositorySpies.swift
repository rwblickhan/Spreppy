//
//  RepositorySpies.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 9/29/21.
//

import Combine
import Foundation
@testable import Spreppy

struct RepositorySpies: Repositories {
    let deckRepoSpy = DeckRepositorySpy()
    let cardRepoSpy = CardRepositorySpy()

    var deckRepo: DeckRepository {
        deckRepoSpy
    }

    var cardRepo: CardRepository {
        cardRepoSpy
    }
}

protocol RepositorySpy {
    associatedtype ModelType: Model
    var modelList: CurrentValueSubject<[ModelType], Never> { get }
}

extension RepositorySpy {
    func fetch(_ modelID: UUID) -> (ModelType?, AnyPublisher<ModelType, Never>) {
        let model = modelList.value.first(where: { $0.uuid == modelID })
        let publisher = modelList.compactMap { $0.first(where: { $0.uuid == modelID }) }.eraseToAnyPublisher()
        return (model, publisher)
    }

    func createOrUpdate(_ model: ModelType) {
        var models = modelList.value
        if let (i, _) = modelList.value.enumerated().first(where: { $0.element.uuid == model.uuid }) {
            models[i] = model
        } else {
            models.append(model)
        }
        modelList.send(models)
    }

    func delete(_ model: ModelType) {
        var models = modelList.value
        models.removeAll(where: { $0.uuid == model.uuid })
        modelList.send(models)
    }
}

struct DeckRepositorySpy: RepositorySpy, DeckRepository {
    typealias ModelType = DeckModel
    private(set) var modelList = CurrentValueSubject<[DeckModel], Never>([])

    func fetchDeckList() -> AnyPublisher<[DeckModel], Never> {
        modelList.eraseToAnyPublisher()
    }

    func setDeckList(_ decks: [DeckModel]) {
        modelList.send(decks)
    }
}

struct CardRepositorySpy: RepositorySpy, CardRepository {
    typealias ModelType = CardModel
    private(set) var modelList = CurrentValueSubject<[CardModel], Never>([])
}
