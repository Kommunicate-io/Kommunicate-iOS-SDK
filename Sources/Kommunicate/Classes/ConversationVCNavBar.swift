//
//  CustomNavigationView.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 15/11/18.
//

import Foundation
import ApplozicCore
import ApplozicSwift
import Kingfisher

protocol NavigationBarCallbacks: AnyObject {
    func backButtonPressed()
}

extension NSAttributedString.Key {
    /// Use it to set font for subtitle in navigation bar.
    /// Default: nil
    public static let subtitleFont = NSAttributedString.Key("KMSubtitleFont")
}

class ConversationVCNavBar: UIView, Localizable {

    var configuration: KMConversationViewConfiguration!
    weak var delegate: NavigationBarCallbacks?
    var localizationFileName: String!
    
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "icon_back", in: Bundle.kommunicate, compatibleWith: nil)
        image = image?.withRenderingMode(.alwaysTemplate).imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = true
        button.accessibilityIdentifier = "BackButton"
        return button
    }()

    var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder", in: Bundle.kommunicate, compatibleWith: nil)
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var profileName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 96, green: 94, blue: 94)
        return label
    }()
    
    lazy var statusIconBackgroundColor: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

    var onlineStatusIcon: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 165, green: 170, blue: 165)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    var onlineStatusText: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 113, green: 110, blue: 110)
        return label
    }()
    
    lazy var profileView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.profileName, self.onlineStatusText])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()

    struct LocalizationKey {
        static let online = "online"
        static let offline = "offline"
        static let awayMode = "awayMode"
        static let noName = "noName"
    }
    
    required init(
        delegate: NavigationBarCallbacks,
        localizationFileName: String,
        configuration: KMConversationViewConfiguration) {
        self.configuration = configuration
        self.delegate = delegate
        self.localizationFileName = localizationFileName
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))

        setupLocalizedLabelTexts()
        setupConstraints()
        setupActions()
        configureBackButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(assignee: ALContact?,channel:ALChannel) {
        setupProfile(assignee,channel)
    }
    
    @objc func backButtonClicked(_ sender: UIButton) {
        delegate?.backButtonPressed()
    }
    
    func setupAppearance() {
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [KMBaseNavigationViewController.self])
        if let textColor = navigationBarProxy.titleTextAttributes?[.foregroundColor] as? UIColor {
            profileName.textColor = textColor
            onlineStatusText.textColor = textColor
        }
        if let titleFont = navigationBarProxy.titleTextAttributes?[.font] as? UIFont {
            profileName.font = titleFont
        }
        if let subtitleFont = navigationBarProxy.titleTextAttributes?[.subtitleFont] as? UIFont {
            onlineStatusText.font = subtitleFont
        }
        if let tintColor = navigationBarProxy.tintColor {
            backButton.tintColor = tintColor
        }
        statusIconBackgroundColor.backgroundColor = navigationBarProxy.barTintColor
    }

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [backButton, profileImage, statusIconBackgroundColor, onlineStatusIcon, profileView])

        //Setup constraints
        backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true

        profileImage.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10).isActive = true
        profileImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        statusIconBackgroundColor.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 0).isActive = true
        statusIconBackgroundColor.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: -10).isActive = true
        statusIconBackgroundColor.widthAnchor.constraint(equalToConstant: 12).isActive = true
        statusIconBackgroundColor.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        onlineStatusIcon.centerXAnchor.constraint(equalTo: statusIconBackgroundColor.centerXAnchor).isActive = true
        onlineStatusIcon.centerYAnchor.constraint(equalTo: statusIconBackgroundColor.centerYAnchor).isActive = true
        onlineStatusIcon.widthAnchor.constraint(equalToConstant: 10).isActive = true
        onlineStatusIcon.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        profileView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 5).isActive = true
        profileView.topAnchor.constraint(equalTo: profileImage.topAnchor).isActive = true
        profileView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
    }
    
    private func configureBackButton() {
        if configuration.hideBackButton {
            backButton.isHidden = true
        }
        guard let image = configuration.imageForBackButton else {
            return
        }
        backButton.setImage(image.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
    }
    
    private func setupProfile(_ contact: ALContact?,_ channel:ALChannel) {
        var url: URL?

        if let imageUrl = channel.channelImageURL {
            url = URL(string: imageUrl)
        }
        if(channel.type == Int16(SUPPORT_GROUP.rawValue)){
            setupOnlineStatus(contact)
        }

        guard let placeHolderImage = placeHolderImage(channel: channel) else {
            return
        }

        setupProfileNameAndImage(name:  channel.name, imageUrl: url, placeHolderImage: placeHolderImage)
    }
    
    func setupProfileNameAndImage(name:String,imageUrl:URL?,placeHolderImage:UIImage)  {
        
        if let downloadURL = imageUrl {
            let resource = ImageResource(downloadURL: downloadURL, cacheKey: downloadURL.absoluteString)
            self.profileImage.kf.setImage(with: resource, placeholder: placeHolderImage)
        } else {
            self.profileImage.image = placeHolderImage
        }
        profileName.text = name
    }

    private func placeHolderImage(channel:ALChannel) -> UIImage? {
        var placeHolder : UIImage?

        if(channel.type == Int16(SUPPORT_GROUP.rawValue)) {
            placeHolder  = UIImage(named: "placeholder", in: Bundle.kommunicate, compatibleWith: nil)
        }else {
            placeHolder  = UIImage(named: "groupPlaceholder", in: Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)
        }
        return placeHolder
    }
    
    private func setupOnlineStatus(_ contact: ALContact?) {
        guard let alContact = contact else {
            return
        }
        if (alContact.connected || alContact.roleType == 1) {
            guard !alContact.isInAwayMode else {
                onlineStatusText.text = localizedString(
                    forKey: LocalizationKey.awayMode,
                    fileName: localizationFileName)
                onlineStatusIcon.backgroundColor = .background(.darkYellow)
                return
            }
            onlineStatusText.text = localizedString(
                forKey: LocalizationKey.online,
                fileName: localizationFileName)
            onlineStatusIcon.backgroundColor = UIColor(red: 28, green: 222, blue: 20)
        } else {
            onlineStatusText.text = localizedString(
                forKey: LocalizationKey.offline,
                fileName: localizationFileName)
            onlineStatusIcon.backgroundColor = UIColor(red: 165, green: 170, blue: 165)
        }
    }

    private func setupLocalizedLabelTexts() {
        self.onlineStatusText.text = localizedString(
            forKey: LocalizationKey.offline,
            fileName: localizationFileName)
        self.profileName.text = localizedString(
            forKey: LocalizationKey.noName,
            fileName: localizationFileName)
    }
    
}
