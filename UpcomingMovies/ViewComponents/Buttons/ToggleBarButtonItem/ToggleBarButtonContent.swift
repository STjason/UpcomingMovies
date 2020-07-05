//
//  ToggleBarButtonItemState.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/4/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UIKit

struct ToggleBarButtonItemContent {
    
    let display: ToggleBarButtonItemDisplay
    let accessibilityLabel: String?
    let accessibilityHint: String? = nil
    
    init(display: ToggleBarButtonItemDisplay,
         accessibilityLabel: String = nil,
         accessibilityHint: String? = nil) {
        self.display = display
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }
    
}
