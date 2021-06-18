import XCTest
@testable import ScopedJsonDecoder

final class ScopedJsonDecoderTests: XCTestCase {
    let testJson = """
    {
    "HappyPath": {
        "firstKey": "a",
        "secondKey": "b",
        "thirdKey": "c"
    },
    "SnakeCamelMix": {
        "camelKey": "e",
        "snake_key": "f",
        "double_snake_key": "g"
    },
    "outerContainer": {
        "nestedContainer": {
                    "firstKey": "nested a",
                    "secondKey": "nested b",
                    "thirdKey": "nested c",
            "innerNestedContainer": {
                        "camelKey": "inner e",
                        "snake_key": "inner f",
                        "double_snake_key": "inner g"
            }
        },
        "name": "aunnnn"
    }
    }
    """
        .data(using: .utf8)!


    struct HappyPath: Codable,Equatable {
        let firstKey: String
        let secondKey: String
        let thirdKey: String
    }

    struct SnakeCamelMix: Codable,Equatable {
        let camelKey: String
        let snakeKey: String
        let doubleSnakeKey: String
    }

    func testHappyPath() throws {
        let result = try testJson.decode(HappyPath.self, scopedToKey: "HappyPath").get()
        XCTAssert(
            result
            ==
            HappyPath(
                firstKey: "a",
                secondKey: "b",
                thirdKey: "c"
            )
        )

    }

    func testSnakeCamelMix() throws {
        let result = try testJson.decode(
            SnakeCamelMix.self,
            scopedToKey: "SnakeCamelMix",
            .convertFromSnakeCase
        ).get()

        XCTAssert(
            result
            ==
            SnakeCamelMix(
                camelKey: "e",
                snakeKey: "f",
                doubleSnakeKey: "g"
            )
        )
    }

    func testOuterNest() throws {
        let result = try testJson.decode(
            HappyPath.self,
            scopedToKey: "outerContainer.nestedContainer"
        )
        .get()

        XCTAssert(
            result
            ==
            HappyPath(
                firstKey: "nested a",
                secondKey: "nested b",
                thirdKey: "nested c"
            )
        )
    }
    func testInnerNest() throws {
        let result = try testJson.decode(
            SnakeCamelMix.self,
            scopedToKey: "outerContainer.nestedContainer.innerNestedContainer",
            .convertFromSnakeCase
        ).get()

        XCTAssert(
            result
            ==
            SnakeCamelMix(
                camelKey: "inner e",
                snakeKey: "inner f",
                doubleSnakeKey: "inner g")
        )
    }
}
