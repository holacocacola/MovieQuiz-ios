import Foundation


final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case gamesCount          // Для счётчика сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
    private let storage: UserDefaults = .standard
    
    // реализация счетчика сыгранных игр
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    // Лучшая игра типа GameResult
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue)  as? Date ?? Date()
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    // Подсчет avg точности ответов
    var totalAccuracy: Double {
        guard totalQuestionsAsked > 0 else { return 0.0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
    }
    
    // Количество правильных ответов за все игры
    var totalCorrectAnswers: Int {
        get { storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }
    
    // Количество вопросов, заданных за все игры
    var totalQuestionsAsked: Int {
        get { storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue) }
    }
    
    // Метод сохранения текущего результата игры
    func store(current: GameResult) {
        gamesCount += 1                        // увеличиваем счетчик сыгранных игр
        totalCorrectAnswers += current.correct // обновляем количество правильных ответов всего
        totalQuestionsAsked += current.total   // обновляем количество ответов всего
               
        if current.isBetterThan(bestGame) {    // записываем лучший результат, если он пизже сохраненного
            bestGame = current
        }
    }
    
}
