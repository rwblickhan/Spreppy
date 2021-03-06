//
//  AddCardViewController.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/4/21.
//

import Combine
import Foundation
import UIKit

class AddCardViewController: UIViewController, AddCardViewModelDelegate {
    private var viewModel: AddCardViewModel!

    private lazy var cancelBarButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(didTapCancel))
    private lazy var saveBarButton = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(didTapSave))

    private lazy var mainStackView = makeMainStackView()
    private lazy var enterFrontLabel = makeEnterFrontLabel()
    private lazy var frontTextField = makeFrontTextField()
    private lazy var enterBackLabel = makeEnterBackLabel()
    private lazy var backTextField = makeBackTextField()

    private var subscriptions = Set<AnyCancellable>()

    init(deckID: UUID, coordinator: Coordinator, repos: Repositories) {
        super.init(nibName: nil, bundle: nil)
        viewModel = AddCardViewModel(
            deckID: deckID,
            coordinator: coordinator,
            repos: repos,
            delegate: self)
    }

    // MARK: UIViewController

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder:) is unimplemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        // MARK: Navigation Bar

        title = String(localized: "Add Card")
        navigationItem.setLeftBarButton(cancelBarButton, animated: false)
        navigationItem.setRightBarButton(saveBarButton, animated: false)
        navigationItem.largeTitleDisplayMode = .never

        // MARK: View Hierarchy

        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(enterFrontLabel)
        mainStackView.addArrangedSubview(frontTextField)
        mainStackView.addArrangedSubview(enterBackLabel)
        mainStackView.addArrangedSubview(backTextField)

        // MARK: Layout

        mainStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1)
            .isActive = true
        view.keyboardLayoutGuide.bottomAnchor.constraint(
            greaterThanOrEqualToSystemSpacingBelow: mainStackView.bottomAnchor,
            multiplier: 1).isActive = true
        mainStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1)
            .isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: mainStackView.trailingAnchor, multiplier: 1)
            .isActive = true
    }

    // MARK: AddCardViewModelDelegate

    func update(state _: AddCardState) {}

    // MARK: Helpers

    @objc private func didTapCancel() {
        viewModel.handle(.cancelTapped)
    }

    @objc private func didTapSave() {
        viewModel.handle(.saveTapped(frontText: frontTextField.text, backText: backTextField.text))
    }

    // MARK: View Factories

    private func makeMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func makeEnterFrontLabel() -> UILabel {
        let label = UILabel()
        label.text = "Front Text"
        return label
    }

    private func makeEnterBackLabel() -> UILabel {
        let label = UILabel()
        label.text = "Back Text"
        return label
    }

    private func makeFrontTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.systemFill.cgColor
        textField.layer.borderWidth = 1
        textField.textPublisher
            .sink(receiveValue: { [weak self] text in
                self?.viewModel.handle(.frontTextChanged(text))
            })
            .store(in: &subscriptions)
        return textField
    }

    private func makeBackTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.systemFill.cgColor
        textField.layer.borderWidth = 1
        textField.textPublisher
            .sink(receiveValue: { [weak self] text in
                self?.viewModel.handle(.backTextChanged(text))
            })
            .store(in: &subscriptions)
        return textField
    }
}
