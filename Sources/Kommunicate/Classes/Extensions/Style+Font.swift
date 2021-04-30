//
//  Style+Font.swift
//  Kommunicate
//
//  Created by Mukesh on 07/01/20.
//

import Foundation
import UIKit

enum Style {}

extension Style {
    enum Font {
        case ultraLight(size: CGFloat)
        case ultraLightItalic(size: CGFloat)

        case thin(size: CGFloat)
        case thinItalic(size: CGFloat)

        case light(size: CGFloat)
        case lightItalic(size: CGFloat)

        case medium(size: CGFloat)
        case mediumItalic(size: CGFloat)

        case normal(size: CGFloat)
        case italic(size: CGFloat)

        case bold(size: CGFloat)
        case boldItalic(size: CGFloat)

        case condensedBlack(size: CGFloat)
        case condensedBold(size: CGFloat)

        func font() -> UIFont {
            var option: String = ""
            var fontSize: CGFloat = 0

            switch self {
            case let .ultraLight(size): option = "-UltraLight"
            fontSize = size

            case let .ultraLightItalic(size): option = "-UltraLightItalic"
            fontSize = size

            case let .thin(size): option = "-Thin"
            fontSize = size

            case let .thinItalic(size): option = "-ThinItalic"
            fontSize = size

            case let .light(size): option = "-Light"
            fontSize = size

            case let .lightItalic(size): option = "-LightItalic"
            fontSize = size

            case let .medium(size): option = "-Medium"
            fontSize = size

            case let .mediumItalic(size): option = "-MediumItalic"
            fontSize = size

            case let .normal(size): option = ""
            fontSize = size

            case let .italic(size): option = "-Italic"
            fontSize = size

            case let .bold(size): option = "-Bold"
            fontSize = size

            case let .boldItalic(size): option = "-BoldItalic"
            fontSize = size

            case let .condensedBlack(size): option = "-CondensedBlack"
            fontSize = size

            case let .condensedBold(size): option = "-CondensedBold"
            fontSize = size
            }

            return UIFont(name: "HelveticaNeue\(option)", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: fontSize)
        }
    }
}
