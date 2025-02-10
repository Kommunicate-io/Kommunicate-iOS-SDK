//
//  KMStarRattingViewController.swift
//  Kommunicate
//
//  Created by Abhijeet Ranjan on 03/05/24.
//

import Foundation
import UIKit

enum KMStarRatingType: Int, CaseIterable {
    case oneStar = 1
    case twoStar = 2
    case threeStar = 3
    case fourStar = 4
    case fiveStar = 5
}

struct KMFeedback {
    let rating: Int
    let comment: String?
}

class KMStarRattingViewController: UIViewController {
    var selectedStarIndex: Int?
    var closeButtontapped: (() -> Void)?
    var feedbackSubmitted: ((KMFeedback) -> Void)?
    
    let closeButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        let icon = UIImage(named: "cancel_icon", in: Bundle.kommunicate, compatibleWith: nil)
        button.setImage(icon, for: .normal)
        return button
    }()
    
    let rattingTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Style.Font.normal(size: 16).font()
        label.numberOfLines = 1
        label.textColor = .kmDynamicColor(light: .black, dark: .white)
        label.backgroundColor = .clear
        label.text = LocalizedText.title
        label.textAlignment = .center
        return label
    }()
    
    var ratingSelected = 0
    let starRatingView = KMFiveStarView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStarRatingView()
    }

    func setupStarRatingView() {
        starRatingView.maxRating = 5
        starRatingView.filledStarImage = UIImage(named: "rating_star_filled", in: Bundle.kommunicate, compatibleWith: nil)
        starRatingView.emptyStarImage = UIImage(named: "rating_star", in: Bundle.kommunicate, compatibleWith: nil)
        starRatingView.ratingDidChange = { [weak self] rating in
            self?.ratingSelected = rating
        }
        starRatingView.setupStars()
    }
    
    let commentTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Style.Font.normal(size: 16).font()
        label.numberOfLines = 1
        label.textColor = .kmDynamicColor(light: .black, dark: .white)
        label.backgroundColor = .clear
        label.text = LocalizedText.commentSectionTitle
        label.textAlignment = .center
        return label
    }()
    
    let commentsView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder(frame: .zero)
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.font = Style.Font.normal(size: 14).font()
        textView.placeholder = LocalizedText.commentPlaceholder
        textView.placeholderColor = UIColor(netHex: 0xAEAAAA)
        textView.delaysContentTouches = false
        textView.layer.borderColor = UIColor(netHex: 0x848484).cgColor
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 0.7
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .kmDynamicColor(light: .black, dark: .white)
        return textView
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(LocalizedText.submit, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(netHex: 0x5451E2)
        button.layer.cornerRadius = 3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var bottomSheetTransitionDelegate = KMBottomSheetTransitionDelegate()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        addConstraints()
        setupView()
        setupButtons()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addConstraints() {
        view.addViewsForAutolayout(views: [closeButton, rattingTitleLabel, starRatingView, commentTitleLabel, commentsView, submitButton])

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Size.CloseButton.top),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Size.CloseButton.trailing),
            closeButton.heightAnchor.constraint(equalToConstant: Size.CloseButton.height),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor, multiplier: 1.0),
            
            rattingTitleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Size.TitleLabel.top),
            rattingTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Size.RatingView.leading),
            
            starRatingView.topAnchor.constraint(equalTo: rattingTitleLabel.bottomAnchor, constant: Size.RatingView.top),
            starRatingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Size.RatingView.leading),
            starRatingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Size.RatingView.trailing),
            starRatingView.heightAnchor.constraint(equalToConstant: Size.RatingView.height),
            
            commentTitleLabel.topAnchor.constraint(equalTo: starRatingView.bottomAnchor, constant: 20),
            commentTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Size.RatingView.leading),
            
            commentsView.topAnchor.constraint(equalTo: commentTitleLabel.bottomAnchor, constant: 20),
            commentsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            commentsView.heightAnchor.constraint(equalToConstant: Size.CommentsView.height),
            commentsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Size.RatingView.leading),
            commentsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Size.RatingView.trailing),
            
            submitButton.topAnchor.constraint(equalTo: commentsView.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Size.RatingView.leading),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Size.RatingView.trailing),
            submitButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -(Size.SubmitButton.height))
        ])
    }
    
    func setupView() {
        transitioningDelegate = bottomSheetTransitionDelegate
        modalPresentationStyle = .custom
        view.backgroundColor = .kmDynamicColor(light: .white, dark: UIColor.appBarDarkColor())
        view.layer.cornerRadius = 8
    }
    
    func setupButtons() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    @objc func closeTapped() {
        endCommentEditing()
        closeButtontapped?()
    }
    
    @objc func submitTapped() {
        if ratingSelected == 0 {
            print("No rating selected")
            return
        }

        let feedback = KMFeedback(rating: ratingSelected, comment: commentsView.text)
        endCommentEditing()
        feedbackSubmitted?(feedback)
    }

    private func endCommentEditing() {
        if commentsView.isFirstResponder {
            commentsView.resignFirstResponder()
        }
    }
}

class KMBottomSheetTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        return KMBottomSheetController(presentedViewController: presented, presenting: presenting)
    }
}

class KMBottomSheetController: UIPresentationController {
    private var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if let presentedView = presentedView {
            var frame = frameOfPresentedViewInContainerView
            frame.origin.y -= keyboardSize.height
            presentedView.frame = frame
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        containerView.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var keyboardHeight: CGFloat = 0

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView,
              let presentedView = presentedView else { return .zero }

        let containerViewFrame = containerView.bounds
        let targetWidth = containerViewFrame.width
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let targetHeight = presentedView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height

        var frame = containerViewFrame
        frame.origin.y += frame.size.height - targetHeight - keyboardHeight
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        return frame
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}


private extension KMStarRattingViewController {
    enum Size {
        enum CloseButton {
            static let top: CGFloat = 18.0
            static let trailing: CGFloat = -18.0
            static let height: CGFloat = 20.0
        }

        enum TitleLabel {
            static let top: CGFloat = 15.0
        }

        enum RatingView {
            static let top: CGFloat = 20.0
            static let leading: CGFloat = 25.0
            static let trailing: CGFloat = -25.0
            static let height: CGFloat = 40.0
        }

        enum SubmitButton {
            static let height: CGFloat = 40.0
        }

        enum CommentsView {
            static let top: CGFloat = 30.0
            static let height: CGFloat = 64.0
        }
    }
}

extension KMStarRattingViewController: Localizable {
    enum LocalizedText {
        private static let filename = Kommunicate.defaultConfiguration.localizedStringFileName

        static let title = localizedString(forKey: "FiveStarConversationRatingTitle", fileName: filename)
        static let commentPlaceholder = localizedString(forKey: "FiveStarConversationRatingCommentsPlaceholder", fileName: filename)
        static let submit = localizedString(forKey: "FiveStarConversationRatingSubmitButtonTitle", fileName: filename)
        static let restartConversation = localizedString(forKey: "ConversationClosedRestartConversation", fileName: filename)
        static let commentSectionTitle = localizedString(forKey: "FiveStarConversationCommentTitle", fileName: filename)
    }
}
