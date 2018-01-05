// Copyright (c) 2017 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import XCTest
import UIKit
import Quick
import Nimble
import Teapot
@testable import Toshi

class EthereumAPIClientTests: QuickSpec {
    
    let parameters: [String: Any] = [
        "from": "0x011c6dd9565b8b83e6a9ee3f06e89ece3251ef2f",
        "to": "0x011c6dd9565b8b83e6a9ee3f06e89ece3251ef2f",
        "value": "0x330a41d05c8a780a"
    ]

    override func spec() {
        describe("the Ethereum API Client") {
            var subject: EthereumAPIClient!

            context("Happy path 😎") {
                it("creates an unsigned transaction") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "createUnsignedTransaction")
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil { done in
                        subject.createUnsignedTransaction(parameters: self.parameters) { transaction, error in
                            expect(transaction).toNot(beNil())
                            expect(error).to(beNil())
                            
                            expect(transaction).to(equal("0xf085746f6b658d8504a817c800825208945c156634bc3aed611e71550fb8a54480b480cd3b8718972b8c63638a80748080"))
                            done()
                        }
                    }
                }

                it("fetches the transaction Skeleton") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "transactionSkeleton")
                    mockTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil { done in
                        subject.transactionSkeleton(for: self.parameters) { skeleton, error in
                            expect(skeleton).toNot(beNil())
                            expect(error).to(beNil())

                            expect(skeleton.gas).to(equal("0x5208"))
                            expect(skeleton.gasPrice).to(equal("0xa02ffee00"))
                            expect(skeleton.transaction).to(equal("0xf085746f6b656e850a02ffee0082520894011c6dd9565b8b83e6a9ee3f06e89ece3251ef2f8712103c5eee63dc80748080"))
                            
                            done()
                        }
                    }
                }

                it("sends a signed transaction") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "sendSignedTransaction")
                    mockTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil(timeout: 3) { done in
                        let originalTransaction = "0xf085746f6b658d8504a817c800825208945c156634bc3aed611e71550fb8a54480b480cd3b8718972b8c63638a80748080"
                        let transactionSignature = "0x4f80931676670df5b7a919aeaa56ae1d0c2db1792e6e252ee66a30007022200e44f61e710dbd9b24bed46338bed73f21e3a1f28ac791452fde598913867ebbb701"
                        subject.sendSignedTransaction(originalTransaction: originalTransaction, transactionSignature: transactionSignature) { success, transactionHash, error in
                            expect(success).to(beTrue())
                            expect(transactionHash).toNot(beNil())
                            expect(error).to(beNil())
                            
                            expect(transactionHash).to(equal("0xe649f968c44d293128b0fa79a9ccba81ed32d72d34205330aa21a77ab6457ae5"))
                            
                            done()
                        }
                    }
                }

                it("gets the balance") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "getBalance")
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil { done in
                        subject.getBalance(address: "0x1ad0bb2d14595fa6ad885e53eaaa6c82339f9b98") { fetchedBalance, error in
                            expect(fetchedBalance).toNot(beNil())
                            expect(error).to(beNil())
                            
                            expect(fetchedBalance).to(equal(3677824408863012874))
                            
                            done()
                        }
                    }
                }
            }

            context("⚠ Unauthorized error 🔒") {
                it("creates an unsigned transaction") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "createUnsignedTransaction", statusCode: .unauthorized)
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil { done in
                        subject.createUnsignedTransaction(parameters: self.parameters) { transaction, error in
                            expect(transaction).to(beNil())
                            expect(error).toNot(beNil())
                            
                            expect(error?.description).to(equal("Error creating transaction"))
                            
                            done()
                        }
                    }
                }

                it("fetches the transaction Skeleton") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "transactionSkeleton", statusCode: .unauthorized)
                    mockTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil { done in
                        subject.transactionSkeleton(for: self.parameters) { skeleton, error in
                            expect(skeleton).toNot(beNil())
                            expect(error).toNot(beNil())

                            expect(skeleton.gas).to(beNil())
                            expect(skeleton.gasPrice).to(beNil())
                            expect(skeleton.transaction).to(beNil())
                            
                            done()
                        }
                    }
                }

                it("sends a signed transaction") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "sendSignedTransaction", statusCode: .unauthorized)
                    mockTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil(timeout: 3) { done in
                        let originalTransaction = "0xf085746f6b658d8504a817c800825208945c156634bc3aed611e71550fb8a54480b480cd3b8718972b8c63638a80748080"
                        let transactionSignature = "0x4f80931676670df5b7a919aeaa56ae1d0c2db1792e6e252ee66a30007022200e44f61e710dbd9b24bed46338bed73f21e3a1f28ac791452fde598913867ebbb701"
                        subject.sendSignedTransaction(originalTransaction: originalTransaction, transactionSignature: transactionSignature) { success, transactionHash, error in
                            expect(success).to(beFalse())
                            expect(transactionHash).to(beNil())
                            expect(error).toNot(beNil())

                            expect(error?.description).to(equal("An error occurred: request response status reported an issue. Status code: 401."))
                            
                            done()
                        }
                    }
                }

                it("gets the balance") {
                    let mockTeapot = MockTeapot(bundle: Bundle(for: EthereumAPIClientTests.self), mockFilename: "getBalance", statusCode: .unauthorized)
                    subject = EthereumAPIClient(mockTeapot: mockTeapot)

                    waitUntil { done in
                        subject.getBalance(address: "0x1ad0bb2d14595fa6ad885e53eaaa6c82339f9b98") { number, error in
                            expect(number).to(equal(0))
                            expect(error).toNot(beNil())

                            expect(error?.description).to(equal("An error occurred: request response status reported an issue. Status code: 401."))
                            
                            done()
                        }
                    }
                }
            }
        }
    }
}
