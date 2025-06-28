//
//  SearchSuggestions.swift
//  foundation-practices
//
//  Created by Yuunan kin on 2025/06/28.
//

import Foundation
import FoundationModels

@Generable
struct SearchSuggestions {
    @Guide(description: "A list of search terms", .count(10))
    var terms: [String]
}
