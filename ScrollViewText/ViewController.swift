//
//  ViewController.swift
//  ScrollViewText
//
//  Created by Hannes Oud on 06.06.19.
//  Copyright © 2019 IdeasOnCanvas GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    typealias LabelView = UILabel

    let scrollView = UIScrollView()
    let contentView = UIView()

    let label = LabelView()
    let labelWithContentScaleAdjust = LabelView()
    let labelWithDoubleContentScaleAdjust = LabelView()

    let zoomLevelLabel = UILabel()
    let centerButton = UIButton(type: UIButton.ButtonType.custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureScrollViewAndContentView()
        self.configureLabels()
        self.addButtonsAndZoomLevelIndicator()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.center()
    }

    func configureLabels() {

        func configureLabel(_ label: Label, text: String) {
            label.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 16)])
            contentView.addSubview(label)
            label.backgroundColor = UIColor.white
            (label as? UILabel)?.numberOfLines = 0
        }
        func layoutLabelAsVerticalStack(_ labels: [Label]) {
            func rect(below rect: CGRect) -> CGRect {
                return rect.offsetBy(dx: 0.0, dy: rect.height + 10)
            }
            zip(labels.dropLast(), labels.dropFirst()).forEach { (label, label2) in
                label2.frame = rect(below: label.frame)
            }
        }
        let contentRect = self.contentView.bounds
        let mid = CGPoint(x: contentRect.midX, y: contentRect.midY)

        let loremIpsum = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam"

        // Label 1: Looks blurry when zoomed in, and pixely when zoomed out. Zoom around betweeen 5% and 10%, it "glitters"
        configureLabel(self.label, text: "Label 1\n\(loremIpsum)")
        // Label 2: May be blurry when zoomed out <= 20%
        configureLabel(self.labelWithContentScaleAdjust, text: "Label 2 (adjusted)\n\(loremIpsum)")
        // Label 3: Still readable at <= 20, but 4x memory consumption? and starts glittering < 8%
        configureLabel(self.labelWithDoubleContentScaleAdjust, text: "Label 3 (2xadjusted)\n\(loremIpsum)")

        self.label.frame = CGRect(origin: mid, size: CGSize(width: 500, height: 200))
        layoutLabelAsVerticalStack([
            self.label,
            self.labelWithContentScaleAdjust,
            self.labelWithDoubleContentScaleAdjust,
        ])
    }

    // MARK: Point of Interest:

    func adjustLabelScalesToZoomLevel() {
        let displayScale = self.view.window!.screen.scale
        let calculatedContentScale = scrollView.zoomScale * displayScale
        self.labelWithContentScaleAdjust.contentScaleFactor = calculatedContentScale
        self.labelWithDoubleContentScaleAdjust.contentScaleFactor = calculatedContentScale * 2.0
    }

    func configureScrollViewAndContentView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.minimumZoomScale = 0.05
        self.scrollView.bouncesZoom = true
        self.scrollView.delegate = self
        let contentRect = CGRect(x: 0, y: 0, width: 10000, height: 10000)

        self.scrollView.addSubview(self.contentView)
        self.contentView.frame = contentRect

        contentView.backgroundColor = UIColor.lightGray
        self.scrollView.contentSize = contentRect.size
    }


    func addButtonsAndZoomLevelIndicator() {
        self.view.addSubview(self.zoomLevelLabel)
        self.zoomLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        self.zoomLevelLabel.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        self.zoomLevelLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true

        self.centerButton.setTitle("Center", for: .normal)
        self.centerButton.translatesAutoresizingMaskIntoConstraints = false
        self.centerButton.addTarget(self, action: #selector(center), for: .touchUpInside)
        view.addSubview(centerButton)
        self.centerButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        self.centerButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
    }

    @objc func center() {
        self.scrollView.scrollRectToVisible(centerRect, animated: true)
    }

    var centerRect: CGRect {
        return self.labelWithContentScaleAdjust.frame
    }
}

extension ViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scale = NSNumber(value: Double(scrollView.zoomScale))
        self.zoomLevelLabel.text = ViewController.levelFormatter.string(from: scale)
        self.adjustLabelScalesToZoomLevel()
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(self.label.contentScaleFactor)
    }

    private static let levelFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.percent
        return formatter
    }()
}


final class TextDrawingView: UIView {

    var attributedText: NSAttributedString? = NSAttributedString()

    override func draw(_ rect: CGRect) {
        attributedText?.draw(in: rect)
    }

    override var intrinsicContentSize: CGSize {
        return attributedText?.size() ?? .zero
    }
}

protocol Label: UIView {
    var attributedText: NSAttributedString? { get set }
}

extension TextDrawingView: Label {}
extension UILabel: Label {}




//
//enum LayoutManagerFactory {
//
//    static func makeLayoutManager() -> (layoutManager: NSLayoutManager, textContainer: NSTextContainer, textStorage: NSTextStorage) {
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: .zero)
//        let textStorage = NSTextStorage()
//        layoutManager.textStorage = textStorage
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//        return (layoutManager, textContainer, textStorage)
//    }
//}
