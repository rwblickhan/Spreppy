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
    UITableViewDelegate
{
    private lazy var viewModel = DeckListViewModel(
        repository: DeckCoreDateRepository(persistentContainer: AppDelegate.sharedAppDelegate.persistentContainer),
        delegate: self)
    private lazy var dataSource = makeDataSource()
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

    init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Decks", comment: "Title of decks view")
        navigationItem.setLeftBarButton(addBarButton, animated: false)
        navigationItem.setRightBarButton(editBarButton, animated: false)
    }

    // MARK: UIViewController

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder:) is unimplemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        viewModel.handle(.viewDidLoad)
    }

    // MARK: DeckListViewModelDelegate

    func update(state: DeckListState) {
        let oldState = self.state
        self.state = state

        dataSource.apply(state.snapshot, animatingDifferences: true)
        if oldState.isEditing != state.isEditing {
            tableView.setEditing(state.isEditing, animated: true)
            navigationItem.setLeftBarButton(state.isEditing ? nil : addBarButton, animated: true)
            navigationItem.setRightBarButton(state.isEditing ? doneBarButton : editBarButton, animated: true)
        }
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

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, DeckModel> {
        UITableViewDiffableDataSource<Int, DeckModel>(tableView: tableView) { _, _, deckModel in
            let cell = DeckCell()
            cell.configure(with: deckModel)
            return cell
        }
    }
}
