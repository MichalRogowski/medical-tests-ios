//
//  TestsDBRepository.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import CoreData
import Combine

protocol TestsDBRepository {
    func hasPrefilledTests() -> AnyPublisher<Bool, Error>

    func store(categories: [Category]) -> AnyPublisher<Void, Error>
    func tests(for category: String) -> AnyPublisher<LazyList<Test>, Error>
}

struct RealTestDBRepository: TestsDBRepository {

    let persistentStore: PersistentStore

    func hasPrefilledTests() -> AnyPublisher<Bool, Error> {
        let fetchRequest = TestMO.justOneTest()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }

    func store(categories: [Category]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                categories.forEach {
                    $0.store(in: context)
                }
            }
    }

    func tests(for category: String) -> AnyPublisher<LazyList<Test>, Error> {
        let fetchRequest = CategoryMO.categories(for: category)
        return persistentStore
            .fetch(fetchRequest) {
                Category(managedObject: $0)?.tests
            }
            .tryMap { try $0.element(at: 0).lazyList }
            .eraseToAnyPublisher()
    }
}

extension TestMO {
    static func justOneTest() -> NSFetchRequest<TestMO> {
        let request = newFetchRequest()
        request.fetchLimit = 1
        return request
    }
}

extension CategoryMO {
    static func categories(for title: String) -> NSFetchRequest<CategoryMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return request
    }
}
