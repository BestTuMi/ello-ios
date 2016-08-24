////
///  AutoCompleteCellPresenterSpec.swift
//

import Ello
import Quick
import Nimble

class AutoCompleteCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteCellPresenter") {
            beforeEach {
                supressRequestsTo("www.example.com")
            }

            context("username") {
                it("configures a AutoCompleteCell") {
                    let match = AutoCompleteMatch(type: AutoCompleteType.Username, range: ("test".startIndex..<"test".endIndex), text: "test")
                    let result = AutoCompleteResult(name: "Billy", url: "http://www.example.com/avatar")
                    let item = AutoCompleteItem(result: result, type: AutoCompleteType.Username, match: match)

                    let cell: AutoCompleteCell = AutoCompleteCell.loadFromNib()

                    AutoCompleteCellPresenter.configure(cell, item: item)

                    expect(cell.name.text) == "@Billy"
                    expect(cell.avatar.imageURL) == NSURL(string: "http://www.example.com/avatar")!
                    expect(cell.selectionStyle) == UITableViewCellSelectionStyle.None
                    expect(cell.name.textColor) == UIColor.whiteColor()
                    expect(cell.name.font) == UIFont.defaultFont()
                    expect(cell.line.hidden) == false
                    expect(cell.line.backgroundColor) == UIColor.grey3()
                }
            }

            context("emoji") {
                it("configures a AutoCompleteCell") {
                    let match = AutoCompleteMatch(type: AutoCompleteType.Emoji, range: ("test".startIndex..<"test".endIndex), text: "test")
                    let result = AutoCompleteResult(name: "thumbsup", url: "http://www.example.com/emoji")
                    let item = AutoCompleteItem(result: result, type: AutoCompleteType.Emoji, match: match)

                    let cell: AutoCompleteCell = AutoCompleteCell.loadFromNib()

                    AutoCompleteCellPresenter.configure(cell, item: item)

                    expect(cell.name.text) == ":thumbsup:"
                    expect(cell.avatar.imageURL) == NSURL(string: "http://www.example.com/emoji")!
                    expect(cell.selectionStyle) == UITableViewCellSelectionStyle.None
                    expect(cell.name.textColor) == UIColor.whiteColor()
                    expect(cell.name.font) == UIFont.defaultFont()
                    expect(cell.line.hidden) == false
                    expect(cell.line.backgroundColor) == UIColor.grey3()
                }
            }
        }
    }
}
