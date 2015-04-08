//
//  TerminalTests.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 08.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
import XCTest

class TerminalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatTerminalCommandsCanSucceed() {
        var terminal = Terminal()
        XCTAssert(terminal.runTerminalCommandSync("test 1 = 1") != nil, "Terminal should not return nil if command exits with success")
    }
    
    func testThatTerminalCommandsCanFail() {
        var terminal = Terminal()
        XCTAssert(terminal.runTerminalCommandSync("test 1 = 2") == nil, "Terminal should return nil if command exits with failure")
    }

}
