//
//  AvailabilityServiceSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class AvailabilityServiceSpec: QuickSpec {
    override func spec() {
        describe("availability") {
            it("succeeds") {
                ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.endpointClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                var expectedAvailability: Availability? = .None
                let content = ["username": "somename"]
                AvailabilityService().availability(content, success: { availability in
                    expectedAvailability = availability
                }, failure: .None)
                expect(expectedAvailability).toNot(beNil())
            }

            it("fails") {
                ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.errorEndpointsClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                var failed = false
                let content = ["username": "somename"]
                AvailabilityService().availability(content, success: { _ in }, failure: { _, _ in
                    failed = true
                })
                expect(failed) == true
            }
        }
    }
}
