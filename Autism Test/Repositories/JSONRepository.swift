//
//  JSONRepository.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import Foundation
import Combine

protocol JSONRepository {
    func getTests() -> AnyPublisher<[Category], Error>
}

struct RealJSONRepository: JSONRepository {
    func getTests() -> AnyPublisher<[Category], Error> {
        guard let path = Bundle.main.path(forResource: "Tests", ofType: "json") else {
            return Just<[Category]>
                .withErrorType([], Error.self)
                .eraseToAnyPublisher()
        }
        return Future<[Category], Error> { promise in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let categories = try JSONDecoder().decode([Category].self, from: data)
                promise(.success(categories))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
