//
//  GameResult.swift
//  MovieQuiz
//
//  Created by d m on 16.02.2026.
//

import Foundation

struct GameResult {
    let correct: Int //количество правильных ответов
    let total: Int //количество вопросов квиза
    let date: Date //дату завершения раунда
    
    //метод сравнения рекордов(сравнивает с другой такой структурой)
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
    
}
