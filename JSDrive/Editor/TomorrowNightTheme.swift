import Runestone
import UIKit

public final class TomorrowNightTheme: EditorTheme {
    public let backgroundColor = UIColor(hexString: "#1D1F20")
    public let userInterfaceStyle: UIUserInterfaceStyle = .dark

    public let font: UIFont = .monospacedSystemFont(ofSize: 11, weight: .regular)
    public let textColor = UIColor(hexString: "#C5C7C5")

    public let gutterBackgroundColor = UIColor(hexString: "#282A2D")
    public let gutterHairlineColor = UIColor(hexString: "#959795")

    public let lineNumberColor = UIColor(hexString: "#C5C7C5").withAlphaComponent(0.5)
    public let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 11, weight: .regular)

    public let selectedLineBackgroundColor = UIColor(hexString: "#282A2D")
    public let selectedLinesLineNumberColor = UIColor(hexString: "#C5C7C5")
    public let selectedLinesGutterBackgroundColor: UIColor = .clear

    public let invisibleCharactersColor = UIColor(hexString: "#C5C7C5").withAlphaComponent(0.7)

    public let pageGuideHairlineColor = UIColor(hexString: "#C5C7C5")
    public let pageGuideBackgroundColor = UIColor(hexString: "#282A2D")

    public let markedTextBackgroundColor = UIColor(hexString: "#C5C7C5").withAlphaComponent(0.1)
    public let markedTextBackgroundCornerRadius: CGFloat = 4

    public init() {}

    public func textColor(for rawHighlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(rawHighlightName) else {
            return nil
        }
        switch highlightName {
        case .comment: return UIColor(hexString: "#959795")
        case .operator, .punctuation: return UIColor(hexString: "#C5C7C5").withAlphaComponent(0.75)
        case .property: return UIColor(hexString: "#89BDB7")
        case .function: return UIColor(hexString: "#81A1BD")
        case .string: return UIColor(hexString: "#B5BC68")
        case .number: return UIColor(hexString: "#DE925F")
        case .keyword: return UIColor(hexString: "#B193BA")
        case .variableBuiltin: return UIColor(hexString: "#CC6666")
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
