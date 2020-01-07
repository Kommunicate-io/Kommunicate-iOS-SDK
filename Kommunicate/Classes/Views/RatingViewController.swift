//
//  RatingViewController.swift
//  Kommunicate
//
//  Created by Mukesh on 27/12/19.
//

import Foundation

enum RatingType: Int {
    case sad
    case confused
    case happy
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.text = "Rate the conversation"
        label.textAlignment = .center
        return label
    }()

    // NOTE: Enable this when conversation restart support is added.
    let restartConversationView: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = .lightGray
        label.backgroundColor = .clear
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Have other queries?  Restart conversation"
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
        textView.placeholder = "Add a comment..."
        textView.placeholderColor = UIColor(netHex: 0xaeaaaa)
        textView.delaysContentTouches = false
        textView.layer.borderColor = UIColor(netHex: 0x848484).cgColor
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 0.7
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    let submitButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Submit your rating", for: .normal)
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
        stackView.spacing = 30
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

    init(title: String = "Rate the Conversation") {
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

        let commentsViewHeightConstraint = commentsView.heightAnchor.constraint(equalToConstant: 80)
        commentsViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        let submitButtonHeightConstraint = submitButton.heightAnchor.constraint(equalToConstant: 34)
        submitButtonHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        let ratingViewHeightConstraint = ratingView.heightAnchor.constraint(equalToConstant: 80)
        ratingViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            feedbackStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            feedbackStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            feedbackStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 43),
            bottomConstraint,
            ratingViewHeightConstraint,
            commentsViewHeightConstraint,
            submitButtonHeightConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
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
