//
//  NotificationsViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class NotificationsViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = NotificationsViewController.instantiateFromStoryboard()
        describe("initialization", {

            beforeEach({
                controller = NotificationsViewController.instantiateFromStoryboard()
            })

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a NotificationsViewController", {
                expect(controller).to(beAKindOf(NotificationsViewController.self))
            })

            it("has a tab bar item", {
                expect(controller.tabBarItem).notTo(beNil())

                let selectedImage:UIImage = controller.tabBarItem.valueForKey("selectedImage") as UIImage

                expect(selectedImage).notTo(beNil())
            })

        })
    }
}
