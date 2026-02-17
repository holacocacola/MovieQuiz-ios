import UIKit

// MARK: - View Controller
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    

    // MARK: - Outlets
    @IBOutlet private var buttonNo: UIButton!
    @IBOutlet private var buttonYes: UIButton!

    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!


    // MARK: - State
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10 //общее количество вопросов для квиза. Пусть оно будет равно десяти.
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    private var currentQuestion: QuizQuestion? //вопрос, который видит пользователь.
    private var alertPresenter = AlertPresenter()
    private let statisticService: StatisticServiceProtocol = StatisticService() //инициализация статистики

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        showCurrentQuestion()
        
    }

    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        setAnswerButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        setAnswerButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }

    // MARK: - UI/Render
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        setAnswerButtonsEnabled(true)
    }

    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.restartQuiz()
        }

        alertPresenter.show(in: self, model: model)
    }

    // MARK: - Quiz Flow
    private func showCurrentQuestion() {
        //реализация через ебучий делегат
        questionFactory?.requestNextQuestion()
    
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
            
        currentQuestion = question
        let viewModel = convert(model: question)
            
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            // Сохраняем текущую игру
            let currentGame = GameResult(
                        correct: correctAnswers,
                        total: questionsAmount,
                        date: Date()
                    )
            statisticService.store(current: currentGame)
            
            // Читаем обновлённую статистику и строим текст
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
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }

    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showCurrentQuestion()
    }

    // MARK: - Logic
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //[weak self] что бы не держать контроллер в памятилишний раз
            guard let self else { return }

            self.showNextQuestionOrResult()

            self.imageView.layer.masksToBounds = true
            self.imageView.layer.borderWidth = 0
        }
    }

    // MARK: - Helpers
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // Деактивация/Активация кнопок
    private func setAnswerButtonsEnabled(_ enabled: Bool) {
        // важно: именно isUserInteractionEnabled, чтобы внешний вид не менялся
        buttonNo.isUserInteractionEnabled = enabled
        buttonYes.isUserInteractionEnabled = enabled
    }
}
