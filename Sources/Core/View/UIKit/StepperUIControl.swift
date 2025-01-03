//
//  StepperUIControl.swift
//  SparkStepper
//
//  Created by louis.borlee on 29/11/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import UIKit
import Combine
import SwiftUI
import SparkTheming
import SparkButton
@_spi(SI_SPI) import SparkCommon

/// The UIKit version for the stepper.
public final class StepperUIControl<V>: UIControl where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @ObservedObject private var viewModel: StepperControlViewModel<V>
    private var cancellables = Set<AnyCancellable>()
    private var _isTracking: Bool = false

    private var label = UILabel()
    private var labelLeadingSpacingWidhtConstraint = NSLayoutConstraint()
    private var labelTrailingSpacingWidhtConstraint = NSLayoutConstraint()

    private let leadingSeparator = UIView()
    private let trailingSeparator = UIView()

    /// The stepper's current theme.
    public var theme: Theme {
        get { return self.viewModel.theme }
        set {
            self.viewModel.theme = newValue
            self.decrementButton.theme = newValue
            self.incrementButton.theme = newValue
            self.setLabelSpacings()
        }
    }

    /// A Boolean value indicating whether changes in the stepper’s value generate continuous update events.
    public var isContinuous: Bool = true

    /// The bounds of the stepper.
    public var range: ClosedRange<V> {
        get { return self.viewModel.bounds }
        set { self.viewModel.bounds = newValue }
    }

    /// The distance between each valid value.
    public var step: V.Stride {
        get { return self.viewModel.step }
        set { self.viewModel.step = newValue }
    }

    public override var isEnabled: Bool {
        get { return self.viewModel.isEnabled }
        set { self.viewModel.isEnabled = newValue }
    }

    /// The stepper’s current value.
    public var value: V {
        get { return self.viewModel.value }
        set {
            self.viewModel.setValue(newValue)
            switch (self._isTracking, self.isContinuous) {
            case (false, _):
                break // valueChanged event should only trigger when isTracking is true same as UIStepper
            case (true, false): // valueChanged event should not be sent while tracking when isContinuous is false
                break
            case (true, true):
                self.sendActions(for: .valueChanged)
            }
            self.setNeedsLayout()
        }
    }

    /// A Boolean value that determines whether to repeatedly change the stepper’s value as the user presses and holds a stepper button.
    /// If true, the user pressing and holding on the stepper repeatedly alters value.
    /// The default value for this property is `true`.
    public var autoRepeat = true

    private var valueSubject = PassthroughSubject<V, Never>()
    /// Value changes are sent to the publisher.
    /// Alternative: use addAction(UIAction, for: .valueChanged).
    public var valuePublisher: some Publisher<V, Never> {
        return self.valueSubject
    }

    public private(set) var decrementButton: IconButtonUIView
    public private(set) var incrementButton: IconButtonUIView

    public init(
        theme: any Theme
    ) {
        self.viewModel = .init(
            theme: theme,
            value: 0,
            step: 1.0,
            in: 0...100
        )
        self.decrementButton = .init(
            theme: theme,
            intent: .neutral,
            variant: .ghost,
            size: .medium,
            shape: .square
        )
        self.decrementButton.setImage(.init(systemName: "minus"), for: .normal)
        self.incrementButton = .init(
            theme: theme,
            intent: .neutral,
            variant: .ghost,
            size: .medium,
            shape: .square
        )
        self.incrementButton.setImage(.init(systemName: "plus"), for: .normal)

        super.init(frame: .zero)
        self.clipsToBounds = true

        self.label.textAlignment = .center
        self.label.adjustsFontForContentSizeCategory = true
        self.label.isAccessibilityElement = false

        self.decrementButton.accessibilityIdentifier = StepperAccessibilityIdentifier.decrementButton
        self.incrementButton.accessibilityIdentifier = StepperAccessibilityIdentifier.incrementButton

        self.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            self.valueSubject.send(self.value)
        }), for: .valueChanged)

        self.decrementButton.addAction(.init(handler: { _ in
            self.viewModel.decrement()
        }), for: .touchUpInside)
        self.incrementButton.addAction(.init(handler: { _ in
            self.viewModel.increment()
        }), for: .touchUpInside)

        self.setupView()
        self.setupSubscriptions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let labelLeadingSpacing = UIView()
        let labelTrailingSpacing = UIView()
        self.labelLeadingSpacingWidhtConstraint = labelLeadingSpacing.widthAnchor.constraint(equalToConstant: 0)
        self.labelTrailingSpacingWidhtConstraint = labelTrailingSpacing.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            self.labelLeadingSpacingWidhtConstraint,
            self.labelTrailingSpacingWidhtConstraint,
            self.label.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

        self.setLabelSpacings()

        let labelStackView = UIStackView(
            arrangedSubviews: [
                labelLeadingSpacing,
                self.label,
                labelTrailingSpacing
            ]
        )
        let stackView = UIStackView(
            arrangedSubviews: [
                self.decrementButton,
                self.leadingSeparator,
                labelStackView,
                self.trailingSeparator,
                self.incrementButton
            ]
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        stackView.axis = .horizontal

        self.addSubview(stackView)

        NSLayoutConstraint.stickEdges(from: stackView, to: self)
    }

    private func setLabelSpacings() {
        let spacing = self.viewModel.theme.layout.spacing.medium
        self.labelLeadingSpacingWidhtConstraint.constant = spacing
        self.labelTrailingSpacingWidhtConstraint.constant = spacing
    }

    private func setupSubscriptions() {
        // Text
        self.viewModel.$text.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] newText in
            guard let self else { return }
            self.label.text = newText
            self.decrementButton.accessibilityLabel = self.viewModel.getDecrementAccessibilityLabel(text: newText)
            self.incrementButton.accessibilityLabel = self.viewModel.getIncrementAccessibilityLabel(text: newText)
        }

        // Text Color
        self.viewModel.$textColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] newTextColor in
            guard let self else { return }
            self.label.textColor = newTextColor.uiColor
        }

        // Text Font
        self.viewModel.$textFont.removeDuplicates(by: { lhs, rhs in
            lhs.uiFont == rhs.uiFont
        }).subscribe(in: &self.cancellables) { [weak self] newTextFont in
            guard let self else { return }
            self.label.font = newTextFont.uiFont
        }

        // Background Color
        self.viewModel.$backgroundColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] newBackgroundColor in
            guard let self else { return }
            self.backgroundColor = newBackgroundColor.uiColor
        }

        // Background Color
        self.viewModel.$borderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] newBorderColor in
            guard let self else { return }
            self.setBorderColor(from: newBorderColor)
            self.leadingSeparator.backgroundColor = newBorderColor.uiColor
            self.trailingSeparator.backgroundColor = newBorderColor.uiColor
        }

        // Border Width
        self.viewModel.$borderWidth.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] newBorderWidth in
            guard let self else { return }
            self.setBorderWidth(newBorderWidth)
            [self.leadingSeparator, self.trailingSeparator].forEach {
                $0.removeConstraints($0.constraints)
            }
            NSLayoutConstraint.activate([
                self.leadingSeparator.widthAnchor.constraint(equalToConstant: newBorderWidth),
                self.trailingSeparator.widthAnchor.constraint(equalToConstant: newBorderWidth)
            ])
        }

        // Corner Radius
        self.viewModel.$cornerRadius.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] newCornerRadius in
            guard let self else { return }
            self.setCornerRadius(newCornerRadius)
        }

        // Value
        self.viewModel.$value.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] newValue in
            guard let self,
                  self.value != newValue else { return }
            self.value = newValue
            let accessibilityValue = newValue.formatted()
            self.decrementButton.accessibilityValue = accessibilityValue
            self.incrementButton.accessibilityValue = accessibilityValue
        }

        // Dim
        self.viewModel.$dim.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] newDim in
            self?.alpha = newDim
        }

        // Is Min Value
        self.viewModel.$isMinValue.removeDuplicates().subscribe(in: &self.cancellables) { newIsMinValue in
            self.decrementButton.isEnabled = newIsMinValue != true
        }

        // Is Max Value
        self.viewModel.$isMaxValue.removeDuplicates().subscribe(in: &self.cancellables) { newIsMaxValue in
            self.incrementButton.isEnabled = newIsMaxValue != true
        }
    }

    public func setFormat<F>(_ format: F) where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self.viewModel.setFormat(format)
    }

    public func removeFormat() {
        self.viewModel.removeFormat()
    }
}
