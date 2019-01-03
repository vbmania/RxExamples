//
//  ObservableTests.swift
//  RxExamplesTests
//
//  Created by 유금상 on 17/12/2018.
//  Copyright © 2018 유금상. All rights reserved.
//

import XCTest
import Quick
import Nimble

import RxSwift
import RxTest

class ObservableTests: QuickSpec {

    override func spec() {
        describe("Observable의 일반적인 동작") {
            it("Observable를 subscribe하면 각 단계가 올바로 불린다..", closure: {
                var isOnNextEmited: Bool = false
                var isErrorRaised: Bool = false
                var isCompleted: Bool = false
                var isDisposed: Bool = false

                let underTest = TestableObservable(type: .hot)

                let disposable = underTest.observable.subscribe(onNext: { value in
                    isOnNextEmited = true
                }, onError: { error in
                    isErrorRaised = true
                }, onCompleted: {
                    isCompleted = true
                }, onDisposed: {
                    isDisposed = true
                })

                expect(isOnNextEmited).to(beTrue())
                expect(isErrorRaised).to(beFalse())
                expect(isCompleted).to(beFalse())
                expect(underTest.isDisposing).to(beFalse())
                expect(isDisposed).to(beFalse())

                disposable.dispose()

                expect(isOnNextEmited).to(beTrue())
                expect(isErrorRaised).to(beFalse())
                expect(isCompleted).to(beFalse())
                expect(underTest.isDisposing).to(beTrue())
                expect(isDisposed).to(beTrue())
            })

            it("Observable의 각 항목이 올바로 배출된다.", closure: {
                let underTest = TestableObservable(type: .hot)

                var expectedValues: [Int] = [Int]()
                let disposable = underTest.observable.subscribe(onNext: { value in
                    expectedValues.append(value)
                })

                //바로 다음 줄에 작성한 것은 한 틱에 모두 배출되는 것을 확인하기 위함.
                expect(expectedValues).to(equal([0, 1, 2]))
                disposable.dispose()
            })

            it("Observable의 두번 subscribe 해도 각 항목이 올바로 배출된다.", closure: {
                let underTest = TestableObservable(type: .hot)

                var expectedValues: [Int] = [Int]()
                let disposable = underTest.observable.subscribe(onNext: { value in
                    expectedValues.append(value)
                })
                //바로 다음 줄에 작성한 것은 한 틱에 모두 배출되는 것을 확인하기 위함.
                expect(expectedValues).to(equal([0, 1, 2]))


                var expectedValues2: [Int] = [Int]()
                let disposable2 = underTest.observable.subscribe(onNext: { value in
                    expectedValues2.append(value)
                })
                //바로 다음 줄에 작성한 것은 한 틱에 모두 배출되는 것을 확인하기 위함.
                expect(expectedValues2).to(equal([0, 1, 2]))


                disposable.dispose()
                disposable2.dispose()
            })

            it("Observable를 여러번 subscribe하면 create가 여러번 불린다.", closure: {
                let underTest = TestableObservable(type: .hot)

                _ = underTest.observable.subscribe()
                expect(underTest.subscribeCount).to(equal(1))

                let disposable = underTest.observable.subscribe()
                expect(underTest.subscribeCount).to(equal(2))
                disposable.dispose()
            })

            it("Observable를 여러번 subscribe해도 share하면  create가 한번만 불린다.", closure: {
                let underTest = TestableObservable(type: .hot)

                let sharedObservable = underTest.observable.share()

                var expectedValues: [Int] = [Int]()
                let disposable = sharedObservable.subscribe(onNext: { value in
                    expectedValues.append(value)
                })
                expect(expectedValues).to(equal([0, 1, 2]))
                expect(underTest.subscribeCount).to(equal(1))

                var expectedValues2: [Int] = [Int]()
                let disposable2 = sharedObservable.subscribe(onNext: { value in
                    expectedValues2.append(value)
                })
                expect(expectedValues2).to(equal([])) //배출되는 것은 없음. 실제로 무한 emit이 아니므로.
                expect(underTest.subscribeCount).to(equal(1))

                disposable.dispose()
                disposable2.dispose()
            })

            it("Observable를 이미 dispose된 녀석을 subscribe 한다.", closure: {
                let underTest = TestableObservable(type: .hot)

                let disposable = underTest.observable.subscribe()
                expect(underTest.subscribeCount).to(equal(1))

                disposable.dispose()


                var expectedValues2: [Int] = [Int]()
                let disposable2 = underTest.observable.subscribe(onNext: { value in
                    expectedValues2.append(value)
                })
                //바로 다음 줄에 작성한 것은 한 틱에 모두 배출되는 것을 확인하기 위함.
                expect(expectedValues2).to(equal([0, 1, 2]))
                expect(underTest.subscribeCount).to(equal(2))

                disposable2.dispose()
            })
        }

        describe("Observable의 Operator에서") {
            var scheduler: TestScheduler!
            var observer: TestableObserver<Int>!
            var emitter: PublishSubject<Int>!
            var disposeBag: DisposeBag!
            beforeEach {
                disposeBag = DisposeBag()
                scheduler = TestScheduler(initialClock: 0)
                observer = scheduler.createObserver(Int.self)
                emitter = PublishSubject()
            }
            context("Filtering 중") {
                context("Distinct 는") {
                    it("true를 반환할 경우 스트림을 전달하지 않고, false를 반환하는 경우 스트림을 전달한다.") {
                        // 짝수를 전달하지 않는다.
                        emitter.asObservable().distinctUntilChanged({ (left, right) -> Bool in
                            return right % 2 == 0
                        }).subscribe(observer).disposed(by: disposeBag)

                        scheduler.scheduleAt(100, action: {
                            emitter.onNext(1)
                        })
                        scheduler.scheduleAt(200, action: {
                            emitter.onNext(2)
                        })
                        scheduler.scheduleAt(300, action: {
                            emitter.onNext(3)
                        })
                        scheduler.scheduleAt(400, action: {
                            emitter.onNext(4)
                        })

                        scheduler.start()

                        XCTAssertEqual(observer.events, [next(100, 1), next(300, 3)])
                    }
                }
            }
        }
    }
}
