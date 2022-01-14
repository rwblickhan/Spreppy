//
//  CreateDeckViewController.swift
//  Spreppy
//
//  Created by Sherry Yuan on 11/27/21.
//

import Combine
import Foundation
import UIKit

class CreateDeckViewController: UIViewController, CreateDeckViewModelDelegate {
    private var viewModel: CreateDeckViewModel!

    private lazy var cancelBarButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(didTapCancel))
    private lazy var saveBarButton = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(didTapSave))

    private lazy var mainStackView = makeMainStackView()
    private lazy var enterTitleLabel = makeEnterTitleLabel()
    private lazy var titleTextField = makeTitleTextField()
    private lazy var enterSummaryLabel = makeEnterSummaryLabel()
    private lazy var summaryTextField = makeSummaryTextField()

    private var subscriptions = Set<AnyCancellable>()

    init(coordinator: Coordinator) {
        super.init(nibName: nil, bundle: nil)
        viewModel = CreateDeckViewModel(
            coordinator: coordinator,
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

        title = String(localized: "Add Deck")
        navigationItem.setLeftBarButton(cancelBarButton, animated: false)
        navigationItem.setRightBarButton(saveBarButton, animated: false)
        navigationItem.largeTitleDisplayMode = .never

        // MARK: View Hierarchy

        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(enterTitleLabel)
        mainStackView.addArrangedSubview(titleTextField)
        mainStackView.addArrangedSubview(enterSummaryLabel)
        mainStackView.addArrangedSubview(summaryTextField)

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

    // MARK: CreateDeckViewModelDelegate

    func update(state _: CreateDeckState) {}

    // MARK: Helpers

    @objc private func didTapCancel() {
        viewModel.handle(.cancelTapped)
    }

    @objc private func didTapSave() {
        viewModel.handle(.saveTapped(title: titleTextField.text, summary: summaryTextField.text))
    }

    // MARK: View Factories

    private func makeMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func makeEnterTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Title"
        return label
    }

    private func makeEnterSummaryLabel() -> UILabel {
        let label = UILabel()
        label.text = "Summary"
        return label
    }

    private func makeTitleTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.systemFill.cgColor
        textField.layer.borderWidth = 1
        textField.textPublisher
            .sink(receiveValue: { [weak self] text in
                self?.viewModel.handle(.titleChanged(text))
            })
            .store(in: &subscriptions)
        return textField
    }

    private func makeSummaryTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.systemFill.cgColor
        textField.layer.borderWidth = 1
        textField.textPublisher
            .sink(receiveValue: { [weak self] text in
                self?.viewModel.handle(.summaryChanged(text))
            })
            .store(in: &subscriptions)
        return textField
    }
}
