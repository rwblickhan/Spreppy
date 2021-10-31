//
//  SingleCardView.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/28/21.
//

import Foundation
import UIKit

class SingleCardView: UIView {
    private let frontLabel = UILabel()
    private let backLabel = UILabel()

    init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        layer.cornerRadius = 15
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1

        frontLabel.translatesAutoresizingMaskIntoConstraints = false
        backLabel.translatesAutoresizingMaskIntoConstraints = false
        
        frontLabel.numberOfLines = 0
        backLabel.numberOfLines = 0
        
        // MARK: View Hierarchy
        
        addSubview(frontLabel)
        addSubview(backLabel)
        
        // MARK: Layout
        
        frontLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1).isActive = true
        self.trailingAnchor.constraint(equalToSystemSpacingAfter: frontLabel.trailingAnchor, multiplier: 1).isActive = true
        frontLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2).isActive = true

        backLabel.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: self.leadingAnchor, multiplier: 1).isActive = true
        self.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: backLabel.trailingAnchor, multiplier: 1).isActive = true
        backLabel.topAnchor.constraint(equalToSystemSpacingBelow: frontLabel.bottomAnchor, multiplier: 2).isActive = true
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Unimplemented")
    }

    func configure(with cardModel: CardModel) {
        frontLabel.text = cardModel.frontText
        backLabel.text = cardModel.backText
    }
}
