import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    //метод для сохранения текущего результата игры
    //func store(correct count: Int, total amount: Int)
    
    //или через структуру
    func store(current: GameResult)
    
    
}
