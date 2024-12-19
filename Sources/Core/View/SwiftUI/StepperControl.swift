//
//  StepperControl.swift
//  SparkStepper
//
//  Created by louis.borlee on 29/11/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
import SparkTheming
@_spi(SI_SPI) import SparkCommon
import SparkButton

/// The SwiftUI version for the stepper
public struct StepperControl<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Binding private var value: V

    private var viewModel: StepperControlViewModel<V>

    @Environment (\.isEnabled) private var isEnabled

    private var decrementAccessibilityLabel: String? = nil
    private var incrementAccessibilityLabel: String? = nil

    public init(
        theme: any Theme,
        value: Binding<V>,
        step: V.Stride,
        in bounds: ClosedRange<V>
    ) {
        self._value = value
        self.viewModel = .init(
            theme: theme,
            value: value.wrappedValue,
            step: step,
            in: bounds
        )
    }

    public init<F>(
        theme: any Theme,
        value: Binding<F.FormatInput>,
        step: F.FormatInput.Stride = 1,
        in bounds: ClosedRange<F.FormatInput>,
        format: F
    ) where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self._value = value
        self.viewModel = .init(
            theme: theme,
            value: value.wrappedValue,
            step: step,
            in: bounds,
            format: format
        )
    }

    public var body: some View {
        StepperControlInternal(
            value: self.$value,
            viewModel: self.viewModel,
            customDecrementAccessibilityLabel: self.decrementAccessibilityLabel,
            customIncrementAccessibilityLabel: self.incrementAccessibilityLabel
        )
        .update(isEnabled: self.isEnabled)
    }

    public func incrementAccessibilityLabel(_ label: String) -> Self {
        guard label != self.incrementAccessibilityLabel else { return self }
        var copy = self
        copy.incrementAccessibilityLabel = label
        return copy
    }

    public func decrementAccessibilityLabel(_ label: String) -> Self {
        guard label != self.decrementAccessibilityLabel else { return self }
        var copy = self
        copy.decrementAccessibilityLabel = label
        return copy
    }
}

private struct StepperControlInternal<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Environment (\.stepperButtonsConfiguration) private var buttonsConfiguration

    @Binding private var value: V
    @State private var updateTask: Task<Void, Never>?
    @State private var isTracking: Bool = false
    @ObservedObject private var viewModel: StepperControlViewModel<V>

    private var customDecrementAccessibilityLabel: String?
    private var customIncrementAccessibilityLabel: String?

    init(value: Binding<V>,
         viewModel: StepperControlViewModel<V>,
         customDecrementAccessibilityLabel: String? = nil,
         customIncrementAccessibilityLabel: String? = nil
    ) {
        self._value = value
        self.viewModel = viewModel
        self.customDecrementAccessibilityLabel = customDecrementAccessibilityLabel
        self.customIncrementAccessibilityLabel = customIncrementAccessibilityLabel
    }

    var body: some View {
        ZStack {
            self.viewModel.backgroundColor.color
            HStack(spacing: 0) {
                self.decrementButton()
                self.separator()
                Group {
                    self.spacer()
                    Text(self.viewModel.text)
                        .frame(minWidth: 40)
                    self.spacer()
                }
                .accessibilityHidden(true)
                self.separator()
                self.incrementButton()
            }
        }
        .border(
            width: self.viewModel.borderWidth,
            radius: self.viewModel.cornerRadius,
            colorToken: self.viewModel.borderColor
        )
        .opacity(self.viewModel.dim)
        .compositingGroup()
    }

    func update(isEnabled: Bool) -> Self {
        self.viewModel.isEnabled = isEnabled
        return self
    }

    @ViewBuilder
    private func spacer() -> some View {
        Spacer(minLength: self.viewModel.theme.layout.spacing.medium)
    }

    @ViewBuilder
    private func separator() -> some View {
        self.viewModel.borderColor.color
            .frame(width: self.viewModel.borderWidth)
    }

    @ViewBuilder
    private func decrementButton() -> some View {
        IconButtonView(
            theme: self.viewModel.theme,
            intent: self.buttonsConfiguration.decrement.intent,
            variant: self.buttonsConfiguration.decrement.variant,
            size: .medium,
            shape: .square) {
                if !self.isTracking {
                    self.value = self.viewModel.decrement()
                }
                self.stopUpdating()
            }
            .image(self.buttonsConfiguration.decrement.icon, for: .normal)
            .disabled(self.viewModel.isMinValue)
            .accessibilityValue(self.viewModel.value.formatted())
            .accessibilityLabel(self.getDecrementAccessibilityLabel())
            .accessibilityIdentifier(StepperAccessibilityIdentifier.decrementButton)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        guard !self.isTracking else { return }
                        self.startUpdating(isIncrement: false)
                    }
            )
    }

    private func getDecrementAccessibilityLabel() -> String {
        return self.customDecrementAccessibilityLabel ?? self.viewModel.getDecrementAccessibilityLabel()
    }

    @ViewBuilder
    private func incrementButton() -> some View {
        IconButtonView(
            theme: self.viewModel.theme,
            intent: self.buttonsConfiguration.increment.intent,
            variant: self.buttonsConfiguration.increment.variant,
            size: .medium,
            shape: .square) {
                if !self.isTracking {
                    self.value = self.viewModel.increment()
                }
                self.stopUpdating()
            }
            .image(self.buttonsConfiguration.increment.icon, for: .normal)
            .disabled(self.viewModel.isMaxValue)
            .accessibilityValue(self.viewModel.value.formatted())
            .accessibilityLabel(self.getIncrementAccessibilityLabel())
            .accessibilityIdentifier(StepperAccessibilityIdentifier.incrementButton)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: self.viewModel.interval)
                    .onEnded { _ in
                        guard !self.isTracking else { return }
                        self.startUpdating(isIncrement: true)
                    }
            )
    }

    private func getIncrementAccessibilityLabel() -> String {
        return self.customIncrementAccessibilityLabel ?? self.viewModel.getIncrementAccessibilityLabel()
    }

    private func startUpdating(isIncrement: Bool) {
        guard !self.isTracking else { return }
        self.isTracking = true
        self.updateTask = Task { @MainActor in
            await self.updateRepeatedly(isIncrement: isIncrement)
        }
    }

    private func stopUpdating() {
        self.isTracking = false
        self.updateTask?.cancel()
        self.updateTask = nil
        self.viewModel.resetInterval()
    }

    private func updateRepeatedly(isIncrement: Bool) async {
        while self.isTracking {
            let oldValue = self.value
            self.value = isIncrement ? self.viewModel.increment() : self.viewModel.decrement()
            if oldValue == self.value {
                self.stopUpdating()
            }
            do {
                let nanoseconds = UInt64(self.viewModel.interval * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanoseconds)
            } catch {
                break
            }
            self.viewModel.updateInterval()
        }
    }
}
