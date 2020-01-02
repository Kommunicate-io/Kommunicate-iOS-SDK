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
        // TODO: change this to icon
        button.setTitle("close", for: .normal)
        button.setTitleColor(.black, for: .normal)
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
        label.isHidden = true
        label.text = "Have other queries?  Restart conversation"
        return label
    }()

    let ratingView: FeedbackRatingView = {
        let view = FeedbackRatingView(frame: .zero)
        return view
    }()

    let commentsView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = .link
        textView.textColor = .gray
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.backgroundColor = .lightGray
        textView.delaysContentTouches = false
        return textView
    }()

    // TODO: Color and localization
    let submitButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    lazy var bottomSheetTransitionDelegate = BottomSheetTransitionDelegate()
    private lazy var commentsHeightConstraint = commentsView.heightAnchor.constraint(equalToConstant: 0)
    private lazy var submitButtonHeightConstraint = submitButton.heightAnchor.constraint(equalToConstant: 0)

    private var ratingSelected: RatingType?

    init(title: String = "Rate the Conversation") {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = bottomSheetTransitionDelegate
        modalPresentationStyle = .custom
        view.backgroundColor = .white
        setupView()
        setupButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        ratingView.ratingSelected = {[weak self] rating in
            self?.ratingSelected = rating
            // Show comments section and hide restart button
            self?.commentsHeightConstraint.constant = 80
            self?.submitButtonHeightConstraint.constant = 30
            self?.restartConversationView.isHidden = true
            self?.calculatePreferredSize()
        }
        view.layer.cornerRadius = 8
        view.addViewsForAutolayout(views: [
            closeButton,
            titleLabel,
            ratingView,
            commentsView,
            restartConversationView,
            submitButton
        ])

        var allConstraints: [NSLayoutConstraint] = [
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 60)
        ]

        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }

        let ratingViewConstraints: [NSLayoutConstraint] = [
            ratingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            ratingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            ratingView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
            ratingView.heightAnchor.constraint(equalToConstant: 80),
        ]

        let commentsViewConstraints = [
            commentsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            commentsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            commentsView.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 10),
            commentsHeightConstraint
        ]

        let titleViewConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
        ]

        let restartViewConstraints = [
            restartConversationView.topAnchor.constraint(equalTo: submitButton.bottomAnchor),
            restartConversationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartConversationView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]

        let submitButtonConstraints = [
            submitButton.topAnchor.constraint(equalTo: commentsView.bottomAnchor, constant: 10),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            submitButtonHeightConstraint
        ]

        allConstraints.append(contentsOf: ratingViewConstraints + titleViewConstraints + restartViewConstraints + commentsViewConstraints + submitButtonConstraints)

        // NOTE: Presentation controller uses constraints to calculate the
        // height of this view so all items should've a top and
        // bottom constraint otherwise view won't be fully visible.
        NSLayoutConstraint.activate(allConstraints)
    }

    func setupButtons() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    @objc func closeTapped() {
        closeButtontapped?()
    }

    @objc func submitTapped() {
        guard let ratingSelected = ratingSelected else {
            print("No rating selected")
            return
        }
        let feedback = Feedback(rating: ratingSelected, comment: commentsView.text)
        feedbackSubmitted?(feedback)
    }


    private func calculatePreferredSize() {
        let targetSize = CGSize(width: view.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
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
