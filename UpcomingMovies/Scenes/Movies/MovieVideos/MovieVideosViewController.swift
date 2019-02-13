//
//  MovieVideosViewController.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/9/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

class MovieVideosViewController: UIViewController, Retryable {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: MovieVideosViewModel? {
        didSet {
            setupBindables()
        }
    }
    
    private var dataSource: SimpleTableViewDataSource<MovieVideoCellViewModel>!
    private var displayedCellsIndexPaths = Set<IndexPath>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNib(cellType: MovieVideoTableViewCell.self)
    }
    
    private func reloadTableView() {
        guard let viewModel = viewModel else { return }
        dataSource = SimpleTableViewDataSource.make(for: viewModel.videoCells)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    /**
     * Configures the tableview footer given the current state of the view.
     */
    private func configureView(withState state: SimpleViewState<Video>) {
        switch state {
        case .loading, .paging:
            tableView.tableFooterView = LoadingFooterView()
            hideErrorView()
        case .populated:
            tableView.tableFooterView = UIView()
            hideErrorView()
        case .empty:
            tableView.tableFooterView = CustomFooterView(message: "There are no trailers to show right now.")
            hideErrorView()
        case .error(let error):
            presentFullScreenErrorView(withErrorMessage: error.localizedDescription,
                                       errorHandler: { [weak self] in
                                        self?.viewModel?.getMovieVideos()
            })
        }
    }

    // MARK: - Reactive Behaviour
    
    private func setupBindables() {
        title = viewModel?.movieTitle
        viewModel?.getMovieVideos()
        viewModel?.viewState.bindAndFire({ [weak self] viewState in
            guard let strongSelf = self else { return }
            strongSelf.configureView(withState: viewState)
            strongSelf.reloadTableView()
        })
    }

}

// MARK: - UITableViewDelegate

extension MovieVideosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel?.playVideo(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !displayedCellsIndexPaths.contains(indexPath) {
            displayedCellsIndexPaths.insert(indexPath)
            TableViewCellAnimator.fadeAnimate(cell: cell)
        }
    }
    
}
