//
//  CardRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/26/21.
//

import Combine
import CoreData
import Foundation

protocol CardRepository {
    func fetch(_ cardID: UUID) -> (CardModel?, AnyPublisher<CardModel, Never>)
    func createOrUpdate(_ cardModel: CardModel)
}

class CardCoreDataRepository: CoreDataRepository<CardModel>, CardRepository {}
