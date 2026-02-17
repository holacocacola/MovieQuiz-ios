//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by d m on 14.02.2026.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
