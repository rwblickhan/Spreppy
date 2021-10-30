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

        translatesAutoresizingMaskIntoConstraints = false
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
