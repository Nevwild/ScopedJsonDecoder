import Foundation

extension JSONDecoder {
    private struct ScopedJsonDecoder {
        private static var nestingKey: CodingUserInfoKey {
            CodingUserInfoKey(rawValue: "nestedContainerKey")!
        }

        private static var rawNestingKey: String {
            "nestedContainerKey"
        }
        private struct Key: CodingKey {
            let stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
                self.intValue = nil
            }

            let intValue: Int?
            init?(intValue: Int) {
                return nil
            }
        }

        private struct ModelResponse<NestedModel: Decodable>: Decodable {
            let nested: NestedModel

            public init(from decoder: Decoder) throws {

                // Split nested paths with '.'
                var keyPaths = (decoder.userInfo[nestingKey] as! String)
                    .split(separator: ".")

                // Get last key to extract in the end
                let lastKey = keyPaths.popLast()

                // Loop getting container until reach final one
                var targetContainer = try decoder.container(keyedBy: Key.self)

                try keyPaths.forEach {k in
                    targetContainer = try targetContainer.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: String(k))!)
                }

                nested = try targetContainer.decode(NestedModel.self, forKey: Key(stringValue: String(lastKey!))!)
            }
        }

        func decode<T: Decodable>(_ type: T.Type, scopedToKey key: String, from data: Data, using decoder: JSONDecoder) -> Result<T,Error> {
            Result {
                decoder.userInfo[ScopedJsonDecoder.nestingKey] = key

                return try decoder.decode(ModelResponse<T>.self, from: data).nested
            }
        }
    }
}

extension JSONDecoder {
    func decode<T:Decodable>(
        _ type: T.Type,
        scopedToKey key: String,
        from data: Data
    ) -> Result<T, Error> {
        ScopedJsonDecoder().decode(
            type.self,
            scopedToKey: key,
            from: data,
            using: self)
    }
}

extension Data{
    func decode<T:Decodable>(
        _ type: T.Type,
        scopedToKey key: String,
        _ keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil
    ) -> Result<T, Error> {
        let decoder = JSONDecoder()
        guard let strategy = keyDecodingStrategy else {
            return decoder.decode(
                type.self,
                scopedToKey: key,
                from: self
            )
        }
        decoder.keyDecodingStrategy = strategy
        return decoder.decode(
            type.self,
            scopedToKey: key,
            from: self
        )
    }
}
