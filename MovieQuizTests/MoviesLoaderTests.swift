import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {

    func testSuccessLoading() throws {
        let networkClientMock = NetworkClientMock(emulateError: false)
        let loader = MoviesLoader(networkClient: networkClientMock)

        let expectation = expectation(description: "Loading Expectation")

        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testFailureLoading() throws {
        let networkClientMock = NetworkClientMock(emulateError: true)
        let loader = MoviesLoader(networkClient: networkClientMock)

        let expectation = expectation(description: "Loading Expectation")

        loader.loadMovies { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Unexpected success")
            }
        }

        waitForExpectations(timeout: 1)
    }
}
