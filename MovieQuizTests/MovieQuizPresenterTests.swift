import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testConvertModelToViewModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let data = Data()
        let question = QuizQuestion(
            imageData: data,
            text: "Question Test",
            correctAnswer: true
        )
        // When
        let viewModel = sut.convert(model: question)
        
        // Then
        XCTAssertEqual(viewModel.question, "Question Test")
        XCTAssertEqual(viewModel.questionNumber,"1/10")
        XCTAssertNotNil(viewModel.image)
    }
}
