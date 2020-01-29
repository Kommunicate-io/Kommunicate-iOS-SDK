//
//  ALKNavigationItem+Extension.swift
//  Kommunicate
//
//  Created by Sunil on 28/01/20.
//

import Foundation
import ApplozicSwift

extension ALKNavigationItem {
    func barButton(target: Any, action: Selector) -> UIBarButtonItem? {
        guard let image = self.buttonImage else {
            guard let text = buttonText else {
                return nil
            }
            let button = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
            button.tag = identifier
            return button
        }

        let scaledImage = image.scale(with: CGSize(width: 25, height: 25))

        guard var buttonImage = scaledImage else {
            return nil
        }
        buttonImage = buttonImage.imageFlippedForRightToLeftLayoutDirection()
        let button = UIBarButtonItem(image: buttonImage, style: .plain, target: target, action: action)
        button.tag = identifier
        return button
    }
}
