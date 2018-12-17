//
//  TestableObservable.swift
//  RxExamplesTests
//
//  Created by 유금상 on 17/12/2018.
//  Copyright © 2018 유금상. All rights reserved.
//

import Foundation
import RxSwift

enum TestableObservableType {
    case hot
    case cold
}

class TestableObservable {

    private (set) var isDisposing: Bool = false
    private (set) var subscribeCount: Int = 0

    let type: TestableObservableType

    lazy var observable: Observable<Int> = {
        return Observable<Int>.create({ [weak self] observer -> Disposable in
            self?.subscribeCount += 1
            observer.onNext(0)
            observer.onNext(1)
            observer.onNext(2)
            if self?.type == .cold {
                observer.onCompleted()
            }
            return Disposables.create {
                self?.isDisposing = true
            }
        })
    }()

    init(type: TestableObservableType = .cold) {
        self.type = type
    }
}
