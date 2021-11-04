//
//  SingleCardView.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/28/21.
//

import Foundation
import UIKit

class SingleCardView: UIView, UIGestureRecognizerDelegate {
    private lazy var frontLabel = makeLabel()
    private lazy var backLabel = makeLabel()

    init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        layer.cornerRadius = 15
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1

        backLabel.isHidden = true

        // MARK: View Hierarchy

        addSubview(frontLabel)
        addSubview(backLabel)

        // MARK: Layout

        frontLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        frontLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: leadingAnchor, multiplier: 1)
            .isActive = true
        trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: frontLabel.trailingAnchor, multiplier: 1)
            .isActive = true
        frontLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 5).isActive = true

        backLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: leadingAnchor, multiplier: 1)
            .isActive = true
        trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: backLabel.trailingAnchor, multiplier: 1)
            .isActive = true
        backLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: frontLabel.bottomAnchor, multiplier: 5)
            .isActive = true

        // MARK: Gesture Recognizers

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTouchDown(_:)))
        gestureRecognizer.minimumPressDuration = 0
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Unimplemented")
    }

    func configure(with cardModel: CardModel) {
        frontLabel.text = cardModel.frontText
        backLabel.text = cardModel.backText
    }

    // MARK: Actions

    @objc private func didTouchDown(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        backLabel.isHidden = false
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }

    // MARK: View Factories

    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
}
