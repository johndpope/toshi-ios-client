//
//  MessageParsingTests.swift
//  Tests
//
//  Created by Ellen Shapiro (Work) on 1/8/18.
//  Copyright © 2018 Bakken&Baeck. All rights reserved.
//

@testable import Toshi
import XCTest

class MessageParsingTests: XCTestCase {
    
    private let otherUserID = "SomeUser"
    private let nonZeroTimeStamp: UInt64 = 5
    
    private lazy var normalThread: TSThread = {
        return TSContactThread(uniqueId: self.otherUserID)!
    }()
    
    private lazy var textMessageBody: String = {
        return "\(SofaType.message.rawValue){\"body\":\"o hai\"}"
    }()
    
    // MARK: - Single User Threads
    
    func testHandlingInvalidKeyMessage() {
        let interactor = ChatInteractor(output: nil, thread: normalThread)
        
        let message = TSInvalidIdentityKeySendingErrorMessage(timestamp: nonZeroTimeStamp,
                                                              in: normalThread,
                                                              failedMessageType: .missingKeyId,
                                                              recipientId: otherUserID)
        
        let parsed = interactor.handleSignalMessage(message)
        
        XCTAssertNil(parsed.fiatValueString)
        XCTAssertNil(parsed.ethereumValueString)
        XCTAssertNil(parsed.attachment)
        XCTAssertNil(parsed.image)
        XCTAssertNil(parsed.title)
        XCTAssertNil(parsed.subtitle)
        XCTAssertNil(parsed.attributedTitle)
        XCTAssertNil(parsed.attributedSubtitle)
        XCTAssertNil(parsed.sofaWrapper)
        XCTAssertNil(parsed.text)
        XCTAssertNil(parsed.attributedText)

        XCTAssertFalse(parsed.isOutgoing)
        XCTAssertFalse(parsed.isActionable)
        XCTAssertFalse(parsed.isDisplayable)
        
        XCTAssertEqual(parsed.messageType, "Text")
        XCTAssertEqual(parsed.signalMessage, message)
        XCTAssertEqual(parsed.senderId, "")
        XCTAssertEqual(parsed.deliveryStatus, .attemptingOut)
    }
    
    func testParsingOutgoingMessage() {
        let interactor = ChatInteractor(output: nil, thread: normalThread)
        
        let message = TSOutgoingMessage(timestamp: nonZeroTimeStamp,
                                        in: normalThread,
                                        messageBody: textMessageBody)
        
        let parsed = interactor.handleSignalMessage(message)
        
        XCTAssertNil(parsed.fiatValueString)
        XCTAssertNil(parsed.ethereumValueString)
        XCTAssertNil(parsed.attachment)
        XCTAssertNil(parsed.image)
        XCTAssertNil(parsed.title)
        XCTAssertNil(parsed.subtitle)
        XCTAssertNil(parsed.attributedTitle)
        XCTAssertNil(parsed.attributedSubtitle)
        XCTAssertNil(parsed.attributedText)
        
        XCTAssertTrue(parsed.isOutgoing)
        XCTAssertTrue(parsed.isDisplayable)

        XCTAssertFalse(parsed.isActionable)
        
        XCTAssertEqual(parsed.messageType, "Text")
        XCTAssertEqual(parsed.signalMessage, message)
        XCTAssertEqual(parsed.text, "o hai")
        XCTAssertEqual(parsed.sofaWrapper?.type, .message)
        XCTAssertEqual(parsed.senderId, "")
        XCTAssertEqual(parsed.deliveryStatus, .attemptingOut)
    }
    
    func testParsingOutgoingMessageWithAttachments() {
        let interactor = ChatInteractor(output: nil, thread: normalThread)
        
        let message = TSOutgoingMessage(timestamp: nonZeroTimeStamp,
                                        in: normalThread,
                                        messageBody: textMessageBody,
                                        attachmentIds: NSMutableArray(array: ["One", "Two"]))
        
        let parsed = interactor.handleSignalMessage(message)

        XCTAssertNil(parsed.fiatValueString)
        XCTAssertNil(parsed.ethereumValueString)
        XCTAssertNil(parsed.attachment) // This should be nil since there arent' actually attachments saved
        XCTAssertNil(parsed.image)
        XCTAssertNil(parsed.title)
        XCTAssertNil(parsed.subtitle)
        XCTAssertNil(parsed.attributedTitle)
        XCTAssertNil(parsed.attributedSubtitle)
        XCTAssertNil(parsed.attributedText)
        
        XCTAssertTrue(parsed.isOutgoing)
        XCTAssertTrue(parsed.isDisplayable)
        
        XCTAssertFalse(parsed.isActionable)
        
        XCTAssertEqual(parsed.messageType, "Image")
        XCTAssertEqual(parsed.signalMessage, message)
        XCTAssertEqual(parsed.text, "o hai")
        XCTAssertEqual(parsed.sofaWrapper?.type, .message)
        XCTAssertEqual(parsed.senderId, "")
        XCTAssertEqual(parsed.deliveryStatus, .attemptingOut)
    }
}
