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

    init() {
        super.init(style: .default, reuseIdentifier: nil)

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2.0),
            contentView.trailingAnchor.constraint(
                equalToSystemSpacingAfter: titleLabel.trailingAnchor,
                multiplier: 1.0),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 2.0),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2.0),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is unimplemented")
    }

    func configure(with deckModel: DeckModel) {
        titleLabel.text = deckModel.title
        accessoryType = .detailDisclosureButton
    }

    // MARK: View Factories

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
