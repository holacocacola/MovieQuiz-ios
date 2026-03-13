import UIKit

// MARK: - View Controller
final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Outlets
    @IBOutlet private weak var buttonNo: UIButton!
    @IBOutlet private weak var buttonYes: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - State
    private var currentQuestion: QuizQuestion? //вопрос, который видит пользователь.
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    //MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - UI
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        setAnswerButtonsEnabled(true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default)
        { [weak self] _ in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        // создаю отложенное действие
        let action: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presenter.retryLoadData() // повторная загрузка данных
        }
        
        // создание модели алерта + отложенное действие action
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: action
        )
        
        // показываю алерт и выполняем отложенное действие
        alertPresenter.show(in: self, model: model)
        
    }
    
    // MARK: - Helpers
    
    // Деактивация/Активация кнопок
    func setAnswerButtonsEnabled(_ isEnabled: Bool) {
        buttonNo.isUserInteractionEnabled = isEnabled
        buttonYes.isUserInteractionEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func highlightImageBorder(isCorrectAnswer isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func removeImageBorderHighlight() {
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderWidth = 0
    }
    
}
