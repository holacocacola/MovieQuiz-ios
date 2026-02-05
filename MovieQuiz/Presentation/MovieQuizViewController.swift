import UIKit

// MARK: - Local Models
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

// MARK: - View Models
private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

// MARK: - View Controller
final class MovieQuizViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var buttonNo: UIButton!
    @IBOutlet private var buttonYes: UIButton!

    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

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

    // MARK: - State
    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentQuestion()
    }

    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: Any) {
        setAnswerButtonsEnabled(false)

        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        setAnswerButtonsEnabled(false)

        let currentQuestion = questions[currentQuestionIndex]
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
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.restartQuiz()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    // MARK: - Quiz Flow
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }

    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }

    private func setAnswerButtonsEnabled(_ enabled: Bool) {
        // важно: именно isUserInteractionEnabled, чтобы внешний вид не менялся
        buttonNo.isUserInteractionEnabled = enabled
        buttonYes.isUserInteractionEnabled = enabled
    }
}
