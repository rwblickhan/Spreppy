//
//  CardStackView.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/28/21.
//

import Foundation
import UIKit

class CardStackView: UIView {
    private let currentCardView = SingleCardView()
    private let nextCardView = SingleCardView()
    private let futureCardView = SingleCardView()
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: View Hierarchy
        
        addSubview(futureCardView)
        addSubview(nextCardView)
        addSubview(currentCardView)
        
        // MARK: Layout
        
        currentCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        currentCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        currentCardView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        currentCardView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        nextCardView.leadingAnchor.constraint(equalToSystemSpacingAfter: currentCardView.leadingAnchor, multiplier: 1).isActive = true
        currentCardView.trailingAnchor.constraint(equalToSystemSpacingAfter: nextCardView.trailingAnchor, multiplier: 1).isActive = true
        currentCardView.topAnchor.constraint(equalToSystemSpacingBelow: nextCardView.topAnchor, multiplier: 1).isActive = true
        nextCardView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        futureCardView.leadingAnchor.constraint(equalToSystemSpacingAfter: nextCardView.leadingAnchor, multiplier: 1).isActive = true
        nextCardView.trailingAnchor.constraint(equalToSystemSpacingAfter: futureCardView.trailingAnchor, multiplier: 1).isActive = true
        nextCardView.topAnchor.constraint(equalToSystemSpacingBelow: futureCardView.topAnchor, multiplier: 1).isActive = true
        futureCardView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unimplemented")
    }
}
