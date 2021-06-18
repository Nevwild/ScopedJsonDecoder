# ScopedJsonDecoder



Based on https://github.com/aunnnn/NestedDecodable, this package allows you to select specific keys to decode from json, regardless of the nesting. 

Installation
SPM:  https://github.com/Nevwild/ScopedJsonDecoder

Usage: 
For the following JSON: 

    let testJSON = """
    {
    "HappyPath":
    {
        "firstKey": "a",
        "secondKey": "b",
        "thirdKey": "c"
    },
    "SnakeCamelMix":
    {
        "camelKey": "e",
        "snake_key": "f",
        "double_snake_key": "g"
    },
    "outerContainer":
    {
        "nestedContainer":
        {
            "firstKey": "nested a",
            "secondKey": "nested b",
            "thirdKey": "nested c",
            "innerNestedContainer":
            {
                "camelKey": "inner e",
                "snake_key": "inner f",
                "double_snake_key": "inner g"
            }
        }
    }
    }
    """
      .data(using: .utf16)!

You can decode to the HappyPath struct

    struct HappyPath: Codable {
        let firstKey: String
        let secondKey: String
        let thirdKey: String
    }

Using the following method on JSONDecoder():

    JSONDecoder().decode(HappyPath.self, scopedToKey: "HappyPath", from: testJson)

    
The same decode() method is available direcly on Data types, so you could achieve the same result with:

    testJson.decode(HappyPath.self, scopedToKey: "HappyPath")
    
If you wanted to decode structs from snake case (or even mixed with camel case): 

    struct SnakeCamelMix: Codable {
        let camelKey: String
        let snakeKey: String
        let doubleSnakeKey: String
    }
Add a .convertFromSnakeCase after your scoped key:

    try testJson.decode(SnakeCamelMix.self, scopedToKey: "SnakeCamelMix", .convertFromSnakeCase)
        
And if you wanted to get the innerNested SnakeCamelMix in the json, seperate the keys using periods, and put the resulting string into the scopedToKey parameter:

    try testJson.decode(SnakeCamelMix.self, scopedToKey: "outerContainer.nestedContainer.innerNestedContainer", .convertFromSnakeCase)


