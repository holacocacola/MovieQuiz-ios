
import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        
        // настройка для тестов: если один тест не прошёл, то следующие тесты запускаться не будут;
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    
    func testYesButton() {
        sleep(5)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    
    func testNoButton() {
        sleep(5)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    func testFinishAlert() {
        sleep(5)
        for _ in 1...10 {
            let tapYesNo = ["Yes","No"].randomElement()!
            app.buttons[tapYesNo].tap()
            sleep(2)
        }
        //print(app.debugDescription)
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2)) // проверка на существование алерта и ждет появление алерта до 2 секунд
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }
    
    func testAlertDismiss() {
        sleep(5)
        for _ in 1...10 {
            let tapYesNo = ["Yes","No"].randomElement()!
            app.buttons[tapYesNo].tap()
            sleep(2)
        }
        //print(app.debugDescription)
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons["Сыграть ещё раз"].tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }


}
