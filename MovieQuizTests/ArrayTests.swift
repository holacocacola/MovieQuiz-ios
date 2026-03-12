import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    //если мы берём элемент по правильному индексу, то получаем правильное значение
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    //если берём по неправильному индексу — получаем пустое значение, то есть nil
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 20]
        
        // Then
        XCTAssertNil(value)
    }
    
}
