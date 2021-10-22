//
//  DeckListViewController.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Foundation
import UIKit

class DeckListViewController: UIViewController,
    DeckListViewModelDelegate,
    UITableViewDelegate {
    private var viewModel: DeckListViewModel!
    private lazy var dataSource = DeckListDiffableDataSource(viewModel: viewModel, tableView: tableView)
    private var state = DeckListState()

    private lazy var tableView = makeTableView()
    private lazy var addBarButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(didTapAdd))
    private lazy var editBarButton = UIBarButtonItem(
        barButtonSystemItem: .edit,
        target: self,
        action: #selector(didTapEdit))
    private lazy var doneBarButton = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(didTapDone))

    init(coordinator: Coordinator, repos: Repositories) {
        super.init(nibName: nil, bundle: nil)

        viewModel = DeckListViewModel(
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

        title = String(localized: "Decks")
        navigationItem.setLeftBarButton(addBarButton, animated: false)
        navigationItem.setRightBarButton(editBarButton, animated: false)
        if traitCollection.userInterfaceIdiom == .phone {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        // MARK: View Hierarchy

        view.addSubview(tableView)

        // MARK: Layout

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        viewModel.handle(.viewDidLoad)
    }

    // MARK: DeckListViewModelDelegate

    func update(state: DeckListState) {
        let oldState = self.state
        self.state = state

        if oldState.decks != state.decks {
            var snapshot = NSDiffableDataSourceSnapshot<Int, DeckModel>()
            snapshot.appendSections([0])
            snapshot.appendItems(state.decks)
            dataSource.apply(snapshot, animatingDifferences: false)
        }

        if oldState.isEditing != state.isEditing {
            tableView.setEditing(state.isEditing, animated: true)
            navigationItem.setLeftBarButton(state.isEditing ? nil : addBarButton, animated: true)
            navigationItem.setRightBarButton(state.isEditing ? doneBarButton : editBarButton, animated: true)
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.handle(.deckSelected(indexPath.row))
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        viewModel.handle(.deckInfoSelected(indexPath.row))
    }

    // MARK: Helpers

    @objc private func didTapAdd() {
        viewModel.handle(.addTapped)
    }

    @objc private func didTapEdit() {
        viewModel.handle(.editTapped)
    }

    @objc private func didTapDone() {
        viewModel.handle(.doneTapped)
    }

    // MARK: View factories

    private func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        return tableView
    }
}

private class DeckListDiffableDataSource: UITableViewDiffableDataSource<Int, DeckModel> {
    private let viewModel: DeckListViewModel

    init(viewModel: DeckListViewModel, tableView: UITableView) {
        self.viewModel = viewModel
        super.init(tableView: tableView) { _, _, deckModel in
            let cell = UITableViewCell()
            var content = cell.defaultContentConfiguration()
            content.text = deckModel.title
            if deckModel.cardUUIDs.count > 0 {
                content.secondaryText = String(localized: "\(deckModel.cardUUIDs.count) cards ready for review")
            }
            cell.contentConfiguration = content
            cell.accessoryType = .detailDisclosureButton
            return cell
        }
    }

    override func tableView(_: UITableView, commit _: UITableViewCell.EditingStyle, forRowAt _: IndexPath) {
        // TODO:
    }
}
