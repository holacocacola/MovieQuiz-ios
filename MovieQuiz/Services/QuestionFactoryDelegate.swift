//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by d m on 14.02.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
