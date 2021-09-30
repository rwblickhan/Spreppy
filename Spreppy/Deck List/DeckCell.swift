//
//  DeckCell.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Foundation
import UIKit

class DeckCell: UITableViewCell {
    private lazy var titleLabel = makeTitleLabel()
    private lazy var deckCountLabel = makeDeckCountLabel()

    init() {
        super.init(style: .default, reuseIdentifier: nil)

        contentView.addSubview(titleLabel)
        contentView.addSubview(deckCountLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1.0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: deckCountLabel.trailingAnchor),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),

            deckCountLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
            contentView.trailingAnchor.constraint(
                equalToSystemSpacingAfter: deckCountLabel.trailingAnchor,
                multiplier: 1.0),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is unimplemented")
    }

    func configure(with deckModel: DeckModel) {
        titleLabel.text = deckModel.title
        deckCountLabel.text = "\(deckModel.cardUUIDs.count)"
    }

    // MARK: View Factories

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeDeckCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
