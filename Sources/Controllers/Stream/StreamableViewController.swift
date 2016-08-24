////
///  StreamableViewController.swift
//

public protocol PostTappedDelegate: class {
    func postTapped(post: Post)
    func postTapped(post: Post, scrollToComment: ElloComment?)
    func postTapped(postId postId: String)
}

public protocol UserTappedDelegate: class {
    func userTapped(user: User)
    func userParamTapped(param: String, username: String?)
}

public protocol CreatePostDelegate: class {
    func createPost(text text: String?, fromController: UIViewController)
    func createComment(post: Post, text: String?, fromController: UIViewController)
    func editComment(comment: ElloComment, fromController: UIViewController)
    func editPost(post: Post, fromController: UIViewController)
}

@objc
public protocol InviteResponder: NSObjectProtocol {
    func onInviteFriends()
}

public class StreamableViewController: BaseElloViewController, PostTappedDelegate {
    @IBOutlet weak var viewContainer: UIView!
    private var showing = false
    public let streamViewController = StreamViewController.instantiateFromStoryboard()

    func setupStreamController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamViewDelegate = self
        streamViewController.userTappedDelegate = self
        streamViewController.postTappedDelegate = self
        streamViewController.createPostDelegate = self

        streamViewController.willMoveToParentViewController(self)
        let containerForStream = viewForStream()
        containerForStream.addSubview(streamViewController.view)
        streamViewController.view.frame = containerForStream.bounds
        streamViewController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
    }

    var scrollLogic: ElloScrollLogic!

    func viewForStream() -> UIView {
        return viewContainer
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showing = true
        willPresentStreamable(navBarsVisible())
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        showing = false
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        willPresentStreamable(navBarsVisible())
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupStreamController()
        scrollLogic = ElloScrollLogic(
            onShow: { [unowned self] scroll in self.showNavBars(scroll) },
            onHide: { [unowned self] in self.hideNavBars() }
        )
    }

    private func willPresentStreamable(navBarsVisible: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(!navBarsVisible, withAnimation: .Slide)
        UIView.setAnimationsEnabled(false)
        if navBarsVisible {
            showNavBars(false)
        }
        else {
            hideNavBars()
        }
        UIView.setAnimationsEnabled(true)
        scrollLogic.isShowing = navBarsVisible
    }

    func navBarsVisible() -> Bool {
        return !(elloTabBarController?.tabBarHidden ?? UIApplication.sharedApplication().statusBarHidden)
    }

    func updateInsets(navBar navBar: UIView?, streamController controller: StreamViewController, navBarsVisible visible: Bool? = nil) {
        let topInset: CGFloat
        let bottomInset: CGFloat
        if visible ?? navBarsVisible() {
            topInset = navBar?.frame.maxY ?? 0
            bottomInset = ElloTabBar.Size.height
        }
        else {
            topInset = 0
            bottomInset = 0
        }

        controller.contentInset.top = topInset
        controller.contentInset.bottom = bottomInset
    }

    func positionNavBar(navBar: UIView, visible: Bool, withConstraint navigationBarTopConstraint: NSLayoutConstraint? = nil, animated: Bool = true) {
        let upAmount: CGFloat
        if visible {
            upAmount = 0
        }
        else {
            upAmount = navBar.frame.size.height + 1
        }
        if let navigationBarTopConstraint = navigationBarTopConstraint {
            navigationBarTopConstraint.constant = upAmount
        }
        animate(animated: animated) {
            navBar.frame.origin.y = -upAmount
        }

        if showing {
            UIApplication.sharedApplication().setStatusBarHidden(!visible, withAnimation: .None)
        }
    }

    func showNavBars(scrollToBottom: Bool) {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }
    }

    func hideNavBars() {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(true, animated: true)
        }
    }

    func scrollToBottom(controller: StreamViewController) {
        if let scrollView = streamViewController.collectionView {
            let contentOffsetY: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            if contentOffsetY > 0 {
                scrollView.scrollEnabled = false
                scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                scrollView.scrollEnabled = true
            }
        }
    }

// MARK: PostTappedDelegate

    public func postTapped(post: Post) {
        self.postTapped(postId: post.id, scrollToComment: nil)
    }

    public func postTapped(post: Post, scrollToComment lastComment: ElloComment?) {
        self.postTapped(postId: post.id, scrollToComment: lastComment)
    }

    public func postTapped(postId postId: String) {
        self.postTapped(postId: postId, scrollToComment: nil)
    }

    private func postTapped(postId postId: String, scrollToComment lastComment: ElloComment?) {
        let vc = PostDetailViewController(postParam: postId)
        vc.scrollToComment = lastComment
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UserTappedDelegate
extension StreamableViewController: UserTappedDelegate {
    public func userTapped(user: User) {
        guard user.relationshipPriority != .Block else { return }
        userParamTapped(user.id, username: user.username)
    }

    public func userParamTapped(param: String, username: String?) {
        guard !alreadyOnUserProfile(param) else {
            return
        }

        let vc = ProfileViewController(userParam: param, username: username)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func alreadyOnUserProfile(user: User) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController {
            let param = profileVC.userParam
            if param[param.startIndex] == "~" {
                let usernamePart = param[param.startIndex.advancedBy(1)..<param.endIndex]
                return user.username == usernamePart
            }
            else {
                return user.id == profileVC.userParam
            }
        }
        return false
    }
}

// MARK: CreatePostDelegate
extension StreamableViewController: CreatePostDelegate {
    public func createPost(text text: String?, fromController: UIViewController) {
        let vc = OmnibarViewController(defaultText: text)
        vc.currentUser = self.currentUser
        vc.onPostSuccess { _ in
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    public func createComment(post: Post, text: String?, fromController: UIViewController) {
        let vc = OmnibarViewController(parentPost: post, defaultText: text)
        vc.currentUser = self.currentUser
        vc.onCommentSuccess { _ in
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    public func editComment(comment: ElloComment, fromController: UIViewController) {
        if OmnibarViewController.canEditRegions(comment.content) {
            let vc = OmnibarViewController(editComment: comment)
            vc.currentUser = self.currentUser
            vc.onCommentSuccess { _ in
                self.navigationController?.popViewControllerAnimated(true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let message = InterfaceString.Post.CannotEditComment
            let alertController = AlertViewController(message: message)
            let action = AlertAction(title: InterfaceString.ThatIsOK, style: .Dark, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    public func editPost(post: Post, fromController: UIViewController) {
        if OmnibarViewController.canEditRegions(post.content) {
            let vc = OmnibarViewController(editPost: post)
            vc.currentUser = self.currentUser
            vc.onPostSuccess() { _ in
                self.navigationController?.popViewControllerAnimated(true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let message = InterfaceString.Post.CannotEditPost
            let alertController = AlertViewController(message: message)
            let action = AlertAction(title: InterfaceString.ThatIsOK, style: .Dark, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: StreamViewDelegate
extension StreamableViewController: StreamViewDelegate {
    public func streamViewCustomLoadFailed() -> Bool {
        return false
    }

    public func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator generator: StreamCellItemGenerator) -> [StreamCellItem]? {
        return nil
    }

    public func streamViewDidScroll(scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    public func streamViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    public func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
}

// MARK: InviteResponder
extension StreamableViewController: InviteResponder {
    public func onInviteFriends() {
        Tracker.sharedTracker.inviteFriendsTapped()
        switch AddressBook.authenticationStatus() {
        case .Authorized:
            proceedWithImport()
        case .NotDetermined:
            promptForAddressBookAccess()
        case .Denied:
            let message = InterfaceString.Friends.AccessDenied
            displayAddressBookAlert(message)
        case .Restricted:
            let message = InterfaceString.Friends.AccessRestricted
            displayAddressBookAlert(message)
        }
    }

    // MARK: - Private

    private func promptForAddressBookAccess() {
        let message = InterfaceString.Friends.ImportPermissionPrompt
        let alertController = AlertViewController(message: message)

        let importMessage = InterfaceString.Friends.ImportAllow
        let action = AlertAction(title: importMessage, style: .Dark) { action in
            Tracker.sharedTracker.importContactsInitiated()
            self.proceedWithImport()
        }
        alertController.addAction(action)

        let cancelMessage = InterfaceString.Friends.ImportNotNow
        let cancelAction = AlertAction(title: cancelMessage, style: .Light) { _ in
            Tracker.sharedTracker.importContactsDenied()
        }
        alertController.addAction(cancelAction)

        logPresentingAlert("StreamableViewController")
        presentViewController(alertController, animated: true, completion: .None)
    }

    private func proceedWithImport() {
        Tracker.sharedTracker.addressBookAccessed()
        AddressBook.getAddressBook { result in
            nextTick {
                switch result {
                case let .Success(addressBook):
                    Tracker.sharedTracker.contactAccessPreferenceChanged(true)
                    let vc = AddFriendsViewController(addressBook: addressBook)
                    vc.currentUser = self.currentUser
                    vc.userTappedDelegate = self
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(vc, animated: true)
                    }
                    else {
                        self.presentViewController(vc, animated: true, completion: nil)
                    }
                case let .Failure(addressBookError):
                    Tracker.sharedTracker.contactAccessPreferenceChanged(false)
                    self.displayAddressBookAlert(addressBookError.rawValue)
                    return
                }
            }
        }
    }

    private func displayAddressBookAlert(message: String) {
        let alertController = AlertViewController(
            message: "We were unable to access your address book\n\(message)"
        )

        let action = AlertAction(title: InterfaceString.OK, style: .Dark, handler: .None)
        alertController.addAction(action)

        logPresentingAlert("StreamableViewController")
        presentViewController(alertController, animated: true, completion: .None)
    }

}
