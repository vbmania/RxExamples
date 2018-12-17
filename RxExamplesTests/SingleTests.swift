//
//  SingleTests.swift
//  RxExamplesTests
//
//  Created by 유금상 on 17/12/2018.
//  Copyright © 2018 유금상. All rights reserved.
//

import XCTest
import Quick
import Nimble

import RxSwift

class SingleTests: QuickSpec {

    override func spec() {
        describe("Single이 Dispose되는 조건") {
            it("subscribe() 만 해도 실행 후 dispose 된다", closure: {
                var isDisposed: Bool = false

                let underTest = Single<Int>.create(subscribe: { observer -> Disposable in
                    observer(.success(0))
                    return Disposables.create {
                        isDisposed = true
                    }
                })

                _ = underTest.subscribe()

                expect(isDisposed).to(beTrue())
            })

            it("Single의 결과가 success인데, onError만 보고 있을 때에도 dispose 된다", closure: {
                var isDisposed: Bool = false

                let underTest = Single<Int>.create(subscribe: { observer -> Disposable in
                    observer(.success(0))
                    return Disposables.create {
                        isDisposed = true
                    }
                })

                _ = underTest.subscribe(onError: { error in
                    guard let error = error as? SingleError else { return }
                    expect(error).to(equal(SingleError.nothing))
                })

                expect(isDisposed).to(beTrue())
            })

            it("Single의 결과가 error인데, onSuccess 만 보고 있을 때에도 dispose 된다", closure: {
                var isDisposed: Bool = false

                let underTest = Single<Int>.create(subscribe: { observer -> Disposable in
                    observer(.error(SingleError.nothing))
                    return Disposables.create {
                        isDisposed = true
                    }
                })

                _ = underTest.subscribe(onSuccess: { value in
                    expect(value).to(equal(0))
                })

                expect(isDisposed).to(beTrue())
            })

            it("Observable을 asSingle로 바꿔서 구독하면 dispose된다.", closure: {
                
            })
        }

    }

}
