//
//  SingleError.swift
//  RxExamplesTests
//
//  Created by 유금상 on 17/12/2018.
//  Copyright © 2018 유금상. All rights reserved.
//

import Foundation

enum SingleError: Error, Equatable {
    case nothing

    static func == (lhs: SingleError, rhs: SingleError) -> Bool {
        switch (lhs, rhs) {
        case (.nothing, .nothing):
            return true
        }
    }
}

