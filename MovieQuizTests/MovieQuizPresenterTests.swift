import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
    func setAnswerButtonsEnabled(_ enabled: Bool) {}
    func removeImageBorderHighlight() {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testConvertModelToViewModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let data = Data()
        let question = QuizQuestion(
            imageData: data,
            text: "Question Test",
            correctAnswer: true
        )
        
        let viewModel = sut.convert(model: question)
        XCTAssertEqual(viewModel.question, "Question Test")
        XCTAssertEqual(viewModel.questionNumber,"1/10")
        XCTAssertNotNil(viewModel.image)
    }
}
