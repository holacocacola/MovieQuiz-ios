import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {

    // MARK: - Properties

    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

    // MARK: - Init

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - Public Methods

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    func retryLoadData() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    // MARK: - Private Methods

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    private func didAnswer(isYes: Bool) {
        viewController?.setAnswerButtonsEnabled(false)
        guard let currentQuestion else { return }
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == isYes)
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.removeImageBorderHighlight()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let currentGame = GameResult(
                correct: correctAnswers,
                total: questionsAmount,
                date: Date()
            )
            statisticService.store(current: currentGame)

            let text = """
                Ваш результат: \(currentGame.correct) из \(currentGame.total)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
