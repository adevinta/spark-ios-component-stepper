//
//  StepperUIView.swift
//  SparkStepper
//
//  Created by louis.borlee on 29/11/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import UIKit
import SparkTheming
import SparkButton
import Combine
@_spi(SI_SPI) import SparkCommon

/// The UIKit version for the stepper.
public final class StepperUIControl<V>: UIControl where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    private let viewModel: StepperViewModel<V>

    private var _isTracking: Bool = false

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            self.leadingButton,
            self.createSeparator(),
            self.createSpacer(),
            self.label,
            self.createSpacer(),
            self.createSeparator(),
            self.trailingButton
        ]
    )

    public lazy var leadingButton: IconButtonUIView = self.createIconButton()
    public lazy var trailingButton: IconButtonUIView = self.createIconButton()

    public let label = UILabel()

    public var theme: any Theme {
        get { return self.viewModel.theme }
        set { self.viewModel.theme = newValue }
    }
    public var value: V {
        get { return self.viewModel.value }
        set {
            self.viewModel.value = newValue
            switch (self._isTracking, self.isContinuous) {
            case (false, _):
                break // valueChanged event should only trigger when isTracking is true
            case (true, false): // valueChanged event should not be sent while tracking when isContinuous is false
                break
            case (true, true):
                self.sendActions(for: .valueChanged)
            }
        }
    }

    public var isContinuous: Bool = true

    public override var isEnabled: Bool {
        get { return self.viewModel.isEnabled }
        set { self.viewModel.isEnabled = newValue }
    }

    private var cancellables = Set<AnyCancellable>()

    private var valueSubject = PassthroughSubject<V, Never>()
    /// Value changes are sent to the publisher.
    /// Alternative: use addAction(UIAction, for: .valueChanged).
    public var valuePublisher: some Publisher<V, Never> {
        return self.valueSubject
    }

    public init(
        theme: any Theme
    ) {
        self.viewModel = .init(
            theme: theme,
            value: .zero,
            step: 0.5,
            in: ClosedRange<V>(uncheckedBounds: (lower: 0.0, upper: 5.0))
        )
        super.init(frame: .zero)
        self.setupViews()
        self.setupSubscriptions()

        self.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            self.valueSubject.send(self.value)
        }), for: .valueChanged)
    }

    private func setupViews() {
        self.backgroundColor = self.viewModel.backgroundColor.uiColor
        self.layer.cornerRadius = self.viewModel.cornerRadius
        self.layer.borderColor = self.viewModel.borderColor.uiColor.cgColor
        self.layer.borderWidth = self.viewModel.borderWidth

        self.label.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        self.label.text = self.viewModel.text
        self.label.font = self.viewModel.textFont.uiFont
        self.label.textColor = self.viewModel.textColor.uiColor
        self.label.textAlignment = .center

        self.setupButtons()

        self.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.stickEdges(from: self.stackView, to: self)
    }

    private func setupButtons() {
        self.leadingButton.setImage(.init(systemName: "minus"), for: .normal)
        self.leadingButton.addAction(.init(handler: { _ in
            self._isTracking = true
            self.viewModel.decrement()
        }), for: .touchDown)

        self.leadingButton.addAction(.init(handler: { _ in
            self._isTracking = false
        }), for: [.touchUpInside, .touchUpOutside])

        self.trailingButton.setImage(.init(systemName: "plus"), for: .normal)
        self.trailingButton.addAction(.init(handler: { _ in
            self._isTracking = true
            self.viewModel.increment()
        }), for: .touchDown)
        self.trailingButton.addAction(.init(handler: { _ in
            self._isTracking = false
        }), for: [.touchUpInside, .touchUpOutside])
    }

    private func setupSubscriptions() {
        self.viewModel.$backgroundColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] backgroundColor in
            guard let self else { return }
            self.backgroundColor = backgroundColor.uiColor
        }
        self.viewModel.$textColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] textColor in
            guard let self else { return }
            self.label.textColor = textColor.uiColor
        }
        self.viewModel.$borderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] borderColor in
            guard let self else { return }
            self.setBorderColor(from: borderColor)
        }
        self.viewModel.$textFont.subscribe(in: &self.cancellables) { [weak self] textFont in
            guard let self else { return }
            self.label.font = textFont.uiFont
        }
        self.viewModel.$borderWidth.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] borderWidth in
            guard let self else { return }
            self.layer.borderWidth = borderWidth
        }
        self.viewModel.$cornerRadius.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] cornerRadius in
            guard let self else { return }
            self.layer.cornerRadius = cornerRadius
        }
        self.viewModel.$dim.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] dim in
            guard let self else { return }
            self.alpha = dim
        }
        self.viewModel.$value.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] value in
            guard let self else { return }
            self.value = value
        }
        self.viewModel.$isMinValue.removeDuplicates().subscribe(in: &self.cancellables) {[weak self] isMinValue in
            guard let self else { return }
            self.leadingButton.isEnabled = isMinValue != true
        }
        self.viewModel.$isMaxValue.removeDuplicates().subscribe(in: &self.cancellables) {[weak self] isMaxValue in
            guard let self else { return }
            self.trailingButton.isEnabled = isMaxValue != true
        }

        self.viewModel.$text.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] text in
            guard let self else { return }
            self.label.text = text
        }

//        self.viewModel.$foregroundColor.removeDuplicates(by: { lhs, rhs in
//            lhs.equals(rhs)
//        })
//        .subscribe(in: &self.cancellables) { [weak self] foregroundColor in
//            guard let self else { return }
//            self.label.textColor = foregroundColor.uiColor
//            self.imageView?.tintColor = foregroundColor.uiColor
//        }
//
//        self.viewModel.$buttonIntent.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] buttonIntent in
//            guard let self else { return }
//            self.buttonView?.intent = buttonIntent
//        }
//        self.viewModel.$buttonVariant.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] buttonVariant in
//            guard let self else { return }
//            self.buttonView?.variant = buttonVariant
//        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFormat<F>(_ format: F?) where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self.viewModel.setFormat(format)
    }

    private func createIconButton() -> IconButtonUIView {
        return .init(
            theme: self.viewModel.theme,
            intent: .neutral,
            variant: .ghost,
            size: .medium,
            shape: .square
        )
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.widthAnchor.constraint(equalToConstant: self.viewModel.borderWidth).isActive = true
        separator.backgroundColor = self.viewModel.borderColor.uiColor
        return separator
    }

    private func createSpacer() -> UIView {
        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: self.viewModel.theme.layout.spacing.medium).isActive = true
        return spacer
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setBorderColor(from: self.viewModel.borderColor)
        }
    }
}
