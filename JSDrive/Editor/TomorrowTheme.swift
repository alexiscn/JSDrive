import Runestone
import UIKit

final class TomorrowTheme: EditorTheme {
    public let backgroundColor = UIColor.white
    public let userInterfaceStyle: UIUserInterfaceStyle = .light

    public let font: UIFont = .monospacedSystemFont(ofSize: 11, weight: .regular)
    public let textColor = UIColor(hexString: "#4D4D4B")

    public let gutterBackgroundColor = UIColor(hexString: "#EEEEEE")
    public let gutterHairlineColor = UIColor(hexString: "#8E908B")

    public let lineNumberColor = UIColor(hexString: "#4D4D4B").withAlphaComponent(0.5)
    public let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 11, weight: .regular)

    public let selectedLineBackgroundColor = UIColor(hexString: "#EEEEEE")
    public let selectedLinesLineNumberColor = UIColor(hexString: "#4D4D4B")
    public let selectedLinesGutterBackgroundColor: UIColor = .clear

    public let invisibleCharactersColor = UIColor(hexString: "#4D4D4B").withAlphaComponent(0.7)

    public let pageGuideHairlineColor = UIColor(hexString: "#4D4D4B")
    public let pageGuideBackgroundColor = UIColor(hexString: "#EEEEEE")

    public let markedTextBackgroundColor = UIColor(hexString: "#4D4D4B").withAlphaComponent(0.1)
    public let markedTextBackgroundCornerRadius: CGFloat = 4

    public init() {}

    public func textColor(for rawHighlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(rawHighlightName) else {
            return nil
        }
        switch highlightName {
        case .comment: return UIColor(hexString: "#8E908B")
        case .operator, .punctuation: return UIColor(hexString: "#4D4D4B").withAlphaComponent(0.75)
        case .property: return UIColor(hexString: "#8B8B8B")
        case .function: return UIColor(hexString: "#4270AD")
        case .string: return UIColor(hexString: "#708B00")
        case .number: return UIColor(hexString: "#F5861F")
        case .keyword: return UIColor(hexString: "#8858A8")
        case .variableBuiltin: return UIColor(hexString: "#C72829")
        }
    }

    public func fontTraits(for rawHighlightName: String) -> FontTraits {
        if let highlightName = HighlightName(rawHighlightName), highlightName == .keyword {
            return .bold
        } else {
            return []
        }
    }
}

