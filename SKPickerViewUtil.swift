//
//  SKPickerViewUtil.swift
//  MoneyEveryday
//
//  Created by 施　坤 on 2021/01/29.
//

import Foundation

public enum SKPickerViewTheme: Int {
    case Light  = 0
    case Dark   = 1
    case defalut   // the theme with system, light theme always ues before iOS 12.0
}

public enum SKPickerEvent {
    case valueChanged
    case confirmPick
    case cancelPick
    case willAppare
    case didAppare
    case willDisappare
    case didDisappare
    case dataParsingError
}

public enum SKDatePickerMinuteInterval: Int {
    case oneMinutes     = 1
    case towMinutes     = 2
    case threeMinutes   = 3
    case fourMinutes    = 4
    case fiveMinutes    = 5
    case sixMinutes     = 6
    case tenMinutes     = 7
    case twelveMinutes  = 12
    case fifteenMinutes = 15
    case twentyMinutes  = 20
    case thirtyMinutes  = 30
}
