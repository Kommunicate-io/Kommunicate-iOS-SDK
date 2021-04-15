//
//  RatingViewController.swift
//  Kommunicate
//
//  Created by Mukesh on 27/12/19.
//

import Foundation
import UIKit

enum RatingType: Int, CaseIterable {
    case sad = 1
    case confused = 5
    case happy = 10
}

struct Feedback {
    let rating: RatingType
    let comment: String?
}

class RatingViewController: UIViewController {

    var closeButtontapped: (() -> Void)?
    var feedbackSubmitted: ((Feedback) -> Void)?

    let closeButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        let icon = UIImage(named: "cancel_icon", in: Bundle.kommunicate, compatibleWith: nil)
        button.setImage(icon, for: .normal)
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Style.Font.normal(size: 16).font()
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.text = LocalizedText.title
        label.textAlignment = .center
        return label
    }()

    // NOTE: Enable this when conversation restart support is added.
    let restartConversationView: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = UIColor(netHex: 0x8b8888)
        label.font = Style.Font.normal(size: 14).font()
        label.backgroundColor = .clear
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedText.restartConversation
        return label
    }()

    let ratingView: FeedbackRatingView = {
        let view = FeedbackRatingView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let commentsView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder(frame: .zero)
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.font = Style.Font.normal(size: 14).font()
        textView.placeholder = LocalizedText.commentPlaceholder
        textView.placeholderColor = UIColor(netHex: 0xaeaaaa)
        textView.delaysContentTouches = false
        textView.layer.borderColor = UIColor(netHex: 0x848484).cgColor
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 0.7
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .black
        return textView
    }()

    let submitButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(LocalizedText.submit, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(netHex: 0x5451e2)
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let feedbackStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Size.CommentsView.top
        return stackView
    }()

    lazy var bottomSheetTransitionDelegate = BottomSheetTransitionDelegate()
    private var ratingSelected: RatingType?

    private lazy var bottomConstraint: NSLayoutConstraint = {
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        let constraint = feedbackStackView.bottomAnchor.constraint(
            lessThanOrEqualTo: bottomAnchor,
            constant: 0
        )
        return constraint
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        addConstraints()
        setupView()
        setupButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    func addConstraints() {
        feedbackStackView.addArrangedSubview(ratingView)
        feedbackStackView.addArrangedSubview(commentsView)
        feedbackStackView.addArrangedSubview(submitButton)
        feedbackStackView.addArrangedSubview(restartConversationView)
        view.addViewsForAutolayout(views: [
            closeButton,
            titleLabel,
            feedbackStackView,
        ])

        let lowPriority = UILayoutPriority(rawValue: 999)
        let commentsViewHeightConstraint = commentsView.heightAnchor
            .constraint(equalToConstant: Size.CommentsView.height)
        commentsViewHeightConstraint.priority = lowPriority
        let submitButtonHeightConstraint = submitButton.heightAnchor
            .constraint(equalToConstant: Size.SubmitButton.height)
        submitButtonHeightConstraint.priority = lowPriority
        let ratingViewHeightConstraint = ratingView.heightAnchor
            .constraint(equalToConstant: Size.RatingView.height)
        ratingViewHeightConstraint.priority = lowPriority

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Size.CloseButton.top),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Size.CloseButton.trailing),
            closeButton.heightAnchor.constraint(equalToConstant: Size.CloseButton.height),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor, multiplier: 1.0),
            feedbackStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Size.RatingView.leading),
            feedbackStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Size.RatingView.trailing),
            feedbackStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.RatingView.top),
            bottomConstraint,
            ratingViewHeightConstraint,
            commentsViewHeightConstraint,
            submitButtonHeightConstraint,
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Size.TitleLabel.top),
        ])
    }

    func setupView() {
        transitioningDelegate = bottomSheetTransitionDelegate
        modalPresentationStyle = .custom
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        commentsView.isHidden = true
        submitButton.isHidden = true
    }

    func setupButtons() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        ratingView.ratingSelected = {[weak self] rating in
            self?.ratingSelected = rating
            self?.commentsView.isHidden = false
            self?.submitButton.isHidden = false
            self?.restartConversationView.isHidden = true
            self?.calculatePreferredSize()
        }
    }

    @objc func closeTapped() {
        endCommentEditing()
        closeButtontapped?()
    }

    @objc func submitTapped() {
        guard let ratingSelected = ratingSelected else {
            print("No rating selected")
            return
        }
        let feedback = Feedback(rating: ratingSelected, comment: commentsView.text)
        endCommentEditing()
        feedbackSubmitted?(feedback)
    }


    private func calculatePreferredSize() {
        let targetSize = CGSize(width: view.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }

    private func endCommentEditing() {
        if commentsView.isFirstResponder {
            commentsView.resignFirstResponder()
        }
    }

    @objc private func onKeyboardShow(notification: Notification) {
        let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard
            commentsView.isFirstResponder,
            let keyboardSize = (keyboardFrameValue as? NSValue)?.cgRectValue
            else {
                return
        }

        let keyboardHeight = -1 * keyboardSize.height
        if bottomConstraint.constant == keyboardHeight { return }
        bottomConstraint.constant = keyboardHeight
        calculatePreferredSize()
    }

    @objc private func onKeyboardHide(notification: Notification) {
        bottomConstraint.constant = 0
        calculatePreferredSize()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

class BottomSheetTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetController(presentedViewController: presented, presenting: presenting)
    }
}

class BottomSheetController: UIPresentationController {

    private var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    override var frameOfPresentedViewInContainerView: CGRect {

        guard let containerView = containerView,
            let presentedView = presentedView else { return .zero }

        let containerViewframe = containerView.bounds
        // Using autolayout to calculate the frame instead of manually
        // setting a frame
        let targetWidth = containerViewframe.width
        let fittingSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        let targetHeight = presentedView.systemLayoutSizeFitting(
            fittingSize, withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel).height

        var frame = containerViewframe
        frame.origin.y += frame.size.height - targetHeight
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        return frame
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {

        guard let containerView = containerView else { return }

        containerView.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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

        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 0
        })
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

private extension RatingViewController {
    enum Size {
        enum CloseButton {
            static let top: CGFloat = 5.0
            static let trailing: CGFloat = -7
            static let height: CGFloat = 20.0
        }

        enum TitleLabel {
            static let top: CGFloat = 19.0
        }

        enum RatingView {
            static let top: CGFloat = 43.0
            static let leading: CGFloat  = 28.0
            static let trailing: CGFloat = -28.0
            static let height: CGFloat = 80.0
        }

        enum SubmitButton {
            static let height: CGFloat = 34.0
        }

        enum CommentsView {
            static let top: CGFloat = 30.0
            static let height: CGFloat = 80.0
        }
    }
}

extension RatingViewController: Localizable {
    enum LocalizedText {
        static private let filename = Kommunicate.defaultConfiguration.localizedStringFileName

        static let title = localizedString(forKey: "ConversationRatingTitle", fileName: filename)
        static let commentPlaceholder = localizedString(forKey: "ConversationRatingCommentsPlaceholder", fileName: filename)
        static let submit = localizedString(forKey: "ConversationRatingSubmitButtonTitle", fileName: filename)
        static let restartConversation = localizedString(forKey: "ConversationClosedRestartConversation", fileName: filename)
    }
}
