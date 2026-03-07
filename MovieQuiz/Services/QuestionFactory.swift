import Foundation



final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
//    func setup(delegate: QuestionFactoryDelegate?) {
//        self.delegate = delegate
//    }
    
    
    // MARK: - Mock Data
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(imageName: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(imageName: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(imageName: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(imageName: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(imageName: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(imageName: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(imageName: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//        QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//        QuizQuestion(imageName: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//        QuizQuestion(imageName: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
//    ]

    // MARK: - QuestionFactoryProtocol
    func requestNextQuestion() {
//        guard let index = (0..<questions.count).randomElement() else {
//            delegate?.didReceiveNextQuestion(question: nil)
//            return
//        }
//        
//        let question = questions[safe: index]
//        delegate?.didReceiveNextQuestion(question: question)
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                // трюк с созданием данных из URL, который в каком-то из следующих спринтов нужно будет переписать
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                self.delegate?.didFailToLoadData(with: error)
            }
            
            let question = makeQuestion(for: movie)

            let quizQuestion = QuizQuestion(
                imageData: imageData,
                text: question.text,
                correctAnswer: question.correctAnswer
            )
            
            
            // Теперь, когда загрузка и обработка данных завершена, пора вернуться в главный поток.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: quizQuestion)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    // Функция генерирует текст вопроса о рейтинге фильма и вычисляет правильный ответ,
    // сравнивая реальный рейтинг фильма со случайно выбранным пороговым значением
    private func makeQuestion(for movie: MostPopularMovie) -> (text: String, correctAnswer: Bool) {
        let rating = Float(movie.rating) ?? 0

        let offset: Float = Bool.random()
            ? Float.random(in: 0.1...1.0)
            : Float.random(in: -1.0 ... -0.1)
        
        // зажимаю сгенерированную оценку между 0 и 10
        let comparisonRating = max(0, min(10, ((rating + offset) * 10).rounded() / 10))

        let text = "Рейтинг этого фильма больше чем \(String(format: "%.1f", comparisonRating))?"
        let correctAnswer = rating > comparisonRating

        return (text, correctAnswer)
    }
    
}
