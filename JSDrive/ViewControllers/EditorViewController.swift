import Foundation
import Runestone
import TreeSitterJavaScriptRunestone
import UIKit

class EditorViewController: UIViewController {
    
    let textView = TextView(frame: .zero)
    
    var toolsView: KeyboardToolsView!
    
    let scriptURL: URL
    
    init(scriptURL: URL) {
        self.scriptURL = scriptURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupTextView()
        loadText()
        
        toolsView = KeyboardToolsView(textView: textView)
        textView.inputAccessoryView = toolsView
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIApplication.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIApplication.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func loadText() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Initialize of TextViewState on a background queue to due avoid blocking the main thread.
            let text = try! String(contentsOf: self.scriptURL)
            let state = TextViewState(text: text, theme: TomorrowTheme(), language: .javaScript)
            DispatchQueue.main.async {
                // setState(_:) should be called on the main thread.
                self.textView.setState(state)
            }
        }
    }
    
    func setupNavBar() {
        let closeItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(handleCloseButtonTapped))
        navigationItem.leftBarButtonItem = closeItem
        
        let saveItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(handleSaveButtonTapped))
        navigationItem.rightBarButtonItem = saveItem
    }
    
    @objc private func handleCloseButtonTapped() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func handleSaveButtonTapped() {
        
    }
    
    func setupTextView() {
        textView.alwaysBounceVertical = true
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.showLineNumbers = true
        textView.lineSelectionDisplayType = .line
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.showPageGuide = true
        textView.pageGuideColumn = 80
        textView.showTabs = false
        textView.showSpaces = false
        textView.showLineBreaks = false
        textView.showSoftLineBreaks = false
        textView.lineHeightMultiplier = 1.3
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        updateInsets(keyboardHeight: 0)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = max(frame.height - view.safeAreaInsets.bottom, 0)
            updateInsets(keyboardHeight: keyboardHeight + view.safeAreaInsets.bottom + 5)
        }
    }
    
    private func updateInsets(keyboardHeight: CGFloat) {
        print(keyboardHeight)
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        textView.automaticScrollInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
}
