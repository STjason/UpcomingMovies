//
//  MovieCreditsViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/13/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

final class MovieCreditsViewModel {
    
    private let movieId: Int
    let movieTitle: String
    
    private let movieClient = MovieClient()
    
    var sections: [MovieCreditsCollapsibleSection] =
        [MovieCreditsCollapsibleSection(type: .cast, opened: true),
         MovieCreditsCollapsibleSection(type: .crew, opened: false)]
    
    var viewState: Bindable<ViewState> = Bindable(.loading)
    
    var castCells: [MovieCreditCellViewModel] {
        return viewState.value.currentCast.map { MovieCreditCellViewModel(cast: $0) }
    }
    
    var crewCells: [MovieCreditCellViewModel] {
        return viewState.value.currentCrew.map { MovieCreditCellViewModel(crew: $0) }
    }
    
    // MARK: - Initializers
    
    init(movieId: Int, movieTitle: String) {
        self.movieId = movieId
        self.movieTitle = movieTitle
    }
    
    // MARK: - Public
    
    func rowCount(for section: Int) -> Int {
        let section = sections[section]
        guard section.opened else { return 0 }
        switch section.type {
        case .cast:
            return castCells.count
        case .crew:
            return crewCells.count
        }
    }
    
    func credit(for section: Int, and index: Int) -> MovieCreditCellViewModel {
        switch sections[section].type {
        case .cast:
            return castCells[index]
        case .crew:
            return crewCells[index]
        }
    }
    
    func headerModel(for index: Int) -> CollapsibleHeaderViewModel {
        let section = sections[index]
        return CollapsibleHeaderViewModel(opened: section.opened,
                                          section: index,
                                          title: section.type.title)
    }
    
    func toggleSection(_ section: Int) -> Bool {
        sections[section].opened = !sections[section].opened
        return sections[section].opened
    }
    
    // MARK: - Networking
    
    func getMovieCredits() {
        movieClient.getMovieCredits(with: movieId) { result in
            switch result {
            case .success(let creditResult):
                guard let creditResult = creditResult else { return }
                self.processCreditResult(creditResult)
            case .failure(let error):
                self.viewState.value = .error(error)
            }
        }
    }
    
    private func processCreditResult(_ creditResult: CreditResult) {
        let fetchedCast = creditResult.cast
        let fetchedCrew = creditResult.crew
        if fetchedCast.isEmpty && fetchedCrew.isEmpty {
            viewState.value = .empty
        } else {
            viewState.value = .populated(fetchedCast, fetchedCrew)
        }
    }
    
}

// MARK: - View sections

extension MovieCreditsViewModel {
    
    struct MovieCreditsCollapsibleSection {
        let type: MovieCreditsViewSection
        var opened: Bool
    }
    
    enum MovieCreditsViewSection {
        case cast, crew
        
        var title: String {
            switch self {
            case .cast:
                return "Cast"
            case .crew:
                return "Crew"
            }
        }
        
    }
    
}

// MARK: - View states

extension MovieCreditsViewModel {
    
    enum ViewState {
        case loading
        case empty
        case populated([Cast], [Crew])
        case error(Error)
        
        var currentCast: [Cast] {
            switch self {
            case .populated(let cast, _):
                return cast
            case .loading, .empty, .error:
                return []
            }
        }
        
        var currentCrew: [Crew] {
            switch self {
            case .populated(_, let crew):
                return crew
            case .loading, .empty, .error:
                return []
            }
        }
        
    }
    
}