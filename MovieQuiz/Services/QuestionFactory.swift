//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by d m on 11.02.2026.
//

import Foundation


//class QuestionFactory: QuestionFactoryProtocol {
class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    func setup(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
    }
    
    
    // MARK: - Mock Data
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    
//    func requestNextQuestion() -> QuizQuestion? {
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
//            return nil
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

//        return questions[safe: index] // 3
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
        
    }
    
}
