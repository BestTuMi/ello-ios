////
///  OmnibarProtocols.swift
//

public protocol OmnibarScreenDelegate: class {
    func omnibarCancel()
    func omnibarPushController(controller: UIViewController)
    func omnibarPresentController(controller: UIViewController)
    func omnibarDismissController()
    func omnibarSubmitted(regions: [OmnibarRegion], buyButtonURL: NSURL?)
}

public protocol OmnibarScreenProtocol: class {
    var delegate: OmnibarScreenDelegate? { get set }
    var isComment: Bool { get set }
    var buyButtonURL: NSURL? { get set }
    var title: String { get set }
    var submitTitle: String { get set }
    var regions: [OmnibarRegion] { get set }
    var avatarURL: NSURL? { get set }
    var avatarImage: UIImage? { get set }
    var currentUser: User? { get set }
    var canGoBack: Bool { get set }
    var isEditing: Bool { get set }
    var interactionEnabled: Bool { get set }
    func resetAfterSuccessfulPost()
    func reportError(title: String, error: NSError)
    func reportError(title: String, errorMessage: String)
    func keyboardWillShow()
    func keyboardWillHide()
    func startEditing()
    func stopEditing()
    func updateButtons()
}
