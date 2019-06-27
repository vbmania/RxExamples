//
//  RelayTests.swift
//  RxExamplesTests
//
//  Created by 유금상 on 27/06/2019.
//  Copyright © 2019 유금상. All rights reserved.
//

import XCTest
import Quick
import Nimble

import RxSwift
import RxCocoa
import RxTest


class RelayClass {

    lazy var message: Observable<String?> = {
        return self.behaviorRelayMessage.asObservable()
    }()

    var behaviorRelayMessage = BehaviorRelay<String?>(value: nil)

}


class RelayTests: QuickSpec {

    var disposeBag = DisposeBag()

    override func spec() {
        describe("Relay의 동작을 알아보자") {
            it("BehaviorRelay를 Observable로 감싼 녀석을 subscribe할 때 곧바로 시그널을 받을 수 있다.", closure: {
                let underTest = RelayClass()
                underTest.behaviorRelayMessage.accept("ABCDE")
                waitUntil(timeout: 3, action: { fulfill in
                    underTest.message
                        .subscribe(onNext: { msg in
                            expect(msg).to(equal("ABCDE"))
                            fulfill()
                        })
                        .disposed(by: self.disposeBag)
                })
            })
        }
    }
}
