//
//  StepperControlViewModelTests.swift
//  SparkStepper
//
//  Created by louis.borlee on 10/12/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import XCTest
import Combine
import SparkTheming
import SparkButton
@testable import SparkStepper
@_spi(SI_SPI) @testable import SparkStepperTesting
@_spi(SI_SPI) import SparkThemingTesting
@_spi(SI_SPI) import SparkCommonTesting


import SwiftUI



final class StepperControlViewModelTests: XCTestCase {

    private let theme = ThemeGeneratedMock.mocked()

    private func createPublishers<V>(viewModel: StepperControlViewModel<V>) -> StepperPublishers<V> where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        let publishers = StepperPublishers(
            text: PublisherMock(publisher: viewModel.$text),
            textFont: PublisherMock(publisher: viewModel.$textFont),
            textColor: PublisherMock(publisher: viewModel.$textColor),
            backgroundColor: PublisherMock(publisher: viewModel.$backgroundColor),
            borderColor: PublisherMock(publisher: viewModel.$borderColor),
            borderWidth: PublisherMock(publisher: viewModel.$borderWidth),
            cornerRadius: PublisherMock(publisher: viewModel.$cornerRadius),
            isMinValue: PublisherMock(publisher: viewModel.$isMinValue),
            isMaxValue: PublisherMock(publisher: viewModel.$isMaxValue),
            dim: PublisherMock(publisher: viewModel.$dim),
            value: PublisherMock(publisher: viewModel.$value)
        )
        publishers.load()
        return publishers
    }

    func test_init_double() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0

        // WHEN
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)

        // THEN
        XCTAssertEqual(viewModel.value, initialValue, "Initial value should be set correctly")
        XCTAssertEqual(viewModel.step, step, "Step should be set correctly")
        XCTAssertEqual(viewModel.bounds, bounds, "Bounds should be set correctly")
        XCTAssertEqual(viewModel.text, "5.0", "Text should reflect the initial value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false for initial value")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false for initial value")
        XCTAssertEqual(viewModel.dim, 1.0, "Initial dim should be 1.0")
        XCTAssertTrue(viewModel.isEnabled, "Stepper should be enabled by default")

        XCTAssertIdentical(viewModel.textFont as? TypographyFontTokenGeneratedMock, self.theme.typography.body1 as? TypographyFontTokenGeneratedMock, "Text font should be set to theme's body1")
        XCTAssertIdentical(viewModel.textColor as? ColorTokenGeneratedMock, self.theme.colors.base.onSurface as? ColorTokenGeneratedMock, "Text color should be set to theme's onSurface")
        XCTAssertIdentical(viewModel.backgroundColor as? ColorTokenGeneratedMock, self.theme.colors.base.surface as? ColorTokenGeneratedMock, "Background color should be set to theme's surface")
        XCTAssertIdentical(viewModel.borderColor as? ColorTokenGeneratedMock, self.theme.colors.base.outline as? ColorTokenGeneratedMock, "Border color should be set to theme's outline")
        XCTAssertEqual(viewModel.borderWidth, self.theme.border.width.small, "Border width should be set to theme's small width")
        XCTAssertEqual(viewModel.cornerRadius, self.theme.border.radius.medium, "Corner radius should be set to theme's medium radius")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertEqual(publishers.textFont.sinkCount, 1, "$textFont should have been called once")
        XCTAssertEqual(publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(publishers.borderColor.sinkCount, 1, "$borderColor should have been called once")
        XCTAssertEqual(publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(publishers.cornerRadius.sinkCount, 1, "$cornerRadius should have been called once")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertEqual(publishers.isMaxValue.sinkCount, 1, "$isMaxValue should have been called once")
        XCTAssertEqual(publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_init_float() {
        // GIVEN
        let initialValue = Float.greatestFiniteMagnitude
        let step: Float = 0.6
        let bounds: ClosedRange<Float> = Float.leastNonzeroMagnitude...Float.greatestFiniteMagnitude

        // WHEN
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )

        let publishers = self.createPublishers(viewModel: viewModel)

        // THEN
        XCTAssertEqual(viewModel.value, initialValue, "Initial value should be set correctly")
        XCTAssertEqual(viewModel.step, step, "Step should be set correctly")
        XCTAssertEqual(viewModel.bounds, bounds, "Bounds should be set correctly")
        XCTAssertEqual(viewModel.text, "3.4028235e+38", "Text should reflect the initial value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false for initial value")
        XCTAssertTrue(viewModel.isMaxValue, "isMaxValue should be true for initial value")
        XCTAssertEqual(viewModel.dim, 1.0, "Initial dim should be 1.0")
        XCTAssertTrue(viewModel.isEnabled, "Stepper should be enabled by default")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertEqual(publishers.textFont.sinkCount, 1, "$textFont should have been called once")
        XCTAssertEqual(publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(publishers.borderColor.sinkCount, 1, "$borderColor should have been called once")
        XCTAssertEqual(publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(publishers.cornerRadius.sinkCount, 1, "$cornerRadius should have been called once")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertEqual(publishers.isMaxValue.sinkCount, 1, "$isMaxValue should have been called once")
        XCTAssertEqual(publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_increment() {
        // GIVEN
        let initialValue: Double = 0.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.increment()

        // THEN
        XCTAssertEqual(viewModel.value, 1.0, "Value should be incremented to 6.0")
        XCTAssertEqual(viewModel.text, "1.0", "Text should reflect the incremented value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false after increment")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false after increment")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_increment_maxValue() {
        // GIVEN
        let initialValue: Float = 9.0
        let step: Float = 1.0
        let bounds: ClosedRange<Float> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.increment()

        // THEN
        XCTAssertEqual(viewModel.value, 10.0, "Value should be incremented to 6.0")
        XCTAssertEqual(viewModel.text, "10.0", "Text should reflect the incremented value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false after increment")
        XCTAssertTrue(viewModel.isMaxValue, "isMaxValue should be true after increment")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertEqual(publishers.isMaxValue.sinkCount, 1, "$isMaxValue should have been called once")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_increment_overflow() {
        // GIVEN
        let initialValue: CGFloat = 9.0
        let step: CGFloat = 4.0
        let bounds: ClosedRange<CGFloat> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.increment()

        // THEN
        XCTAssertEqual(viewModel.value, 10.0, "Value should be incremented to 6.0")
        XCTAssertEqual(viewModel.text, "10.0", "Text should reflect the incremented value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false after increment")
        XCTAssertTrue(viewModel.isMaxValue, "isMaxValue should be true after increment")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertEqual(publishers.isMaxValue.sinkCount, 1, "$isMaxValue should have been called once")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_increment_alreadyMax() {
        // GIVEN
        let initialValue: Float = 10.0
        let step: Float = 4.0
        let bounds: ClosedRange<Float> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.increment()

        // THEN
        XCTAssertEqual(viewModel.value, 10.0, "Value should be incremented to 10.0")
        XCTAssertEqual(viewModel.text, "10.0", "Text should reflect the incremented value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false after increment")
        XCTAssertTrue(viewModel.isMaxValue, "isMaxValue should be true after increment")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_decrement() {
        // GIVEN
        let initialValue: Double = 10.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.decrement()

        // THEN
        XCTAssertEqual(viewModel.value, 9.0, "Value should be decremented to 9.0")
        XCTAssertEqual(viewModel.text, "9.0", "Text should reflect the decremented value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false after decrement")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false after decrement")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertEqual(publishers.isMaxValue.sinkCount, 1, "$isMaxValue should have been called once")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_decrement_minValue() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 5.0
        let bounds: ClosedRange<Double> = 0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.decrement()

        // THEN
        XCTAssertEqual(viewModel.value, 0.0, "Value should be decremented to 0.0")
        XCTAssertEqual(viewModel.text, "0.0", "Text should reflect the decremented value")
        XCTAssertTrue(viewModel.isMinValue, "isMinValue should be true after decrement")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false after decrement")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_decrement_overflow() {
        // GIVEN
        let initialValue: Double = 1.0
        let step: Double = 5.0
        let bounds: ClosedRange<Double> = 0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.decrement()

        // THEN
        XCTAssertEqual(viewModel.value, 0.0, "Value should be decremented to 0.0")
        XCTAssertEqual(viewModel.text, "0.0", "Text should reflect the decremented value")
        XCTAssertTrue(viewModel.isMinValue, "isMinValue should be true after decrement")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false after decrement")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_decrement_alreadyMin() {
        // GIVEN
        let initialValue: Double = 0.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.decrement()

        // THEN
        XCTAssertEqual(viewModel.value, 0.0, "Value should be decremented to 0.0")
        XCTAssertEqual(viewModel.text, "0.0", "Text should reflect the decremented value")
        XCTAssertTrue(viewModel.isMinValue, "isMinValue should be true after decrement")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false after decrement")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_setFormat() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.setFormat(FloatingPointFormatStyle<Double>.Currency(code: "USD", locale: .init(identifier: "en_US")))

        // THEN
        XCTAssertEqual(viewModel.text, "$5.00", "Text should be formatted as an USD currency")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_setFormat_equalText() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.setFormat(FloatingPointFormatStyle<Double>.number.locale(.init(identifier: "en_EN")).precision(.integerAndFractionLength(integer: 1, fraction: 1)))

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_removeFormat() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        viewModel.setFormat(.percent)
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.removeFormat()

        // THEN
        XCTAssertEqual(viewModel.text, "5.0", "Wrong text")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_removeFormat_equalValue() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.removeFormat()

        // THEN
        XCTAssertEqual(viewModel.text, "5.0", "Wrong text")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_isEnabled() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.isEnabled = false

        // THEN
        XCTAssertEqual(viewModel.dim, self.theme.dims.dim3, "Dim should be set to theme's dim3 when disabled")
        XCTAssertIdentical(viewModel.backgroundColor as? ColorTokenGeneratedMock, self.theme.colors.base.onSurface.opacity(self.theme.dims.dim5) as? ColorTokenGeneratedMock, "Background color should be set to theme's onSurface with dim5 opacity when disabled")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertEqual(publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertEqual(publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_isEnabled_equalValue() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.isEnabled = true

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should nit have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_didSet_theme() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        let newTheme = ThemeGeneratedMock.mocked()

        // WHEN
        viewModel.theme = newTheme

        // THEN
        XCTAssertIdentical(viewModel.textFont as? TypographyFontTokenGeneratedMock, newTheme.typography.body1 as? TypographyFontTokenGeneratedMock, "Text font should be updated to new theme's body1")
        XCTAssertIdentical(viewModel.textColor as? ColorTokenGeneratedMock, newTheme.colors.base.onSurface as? ColorTokenGeneratedMock, "Text color should be updated to new theme's onSurface")
        XCTAssertIdentical(viewModel.backgroundColor as? ColorTokenGeneratedMock, newTheme.colors.base.surface as? ColorTokenGeneratedMock, "Background color should be updated to new theme's surface")
        XCTAssertIdentical(viewModel.borderColor as? ColorTokenGeneratedMock, newTheme.colors.base.outline as? ColorTokenGeneratedMock, "Border color should be updated to new theme's outline")
        XCTAssertEqual(viewModel.borderWidth, newTheme.border.width.small, "Border width should be updated to new theme's small width")
        XCTAssertEqual(viewModel.cornerRadius, newTheme.border.radius.medium, "Corner radius should be updated to new theme's medium radius")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertEqual(publishers.textFont.sinkCount, 1, "$textFont should have been called once")
        XCTAssertEqual(publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(publishers.borderColor.sinkCount, 1, "$borderColor should have been called once")
        XCTAssertEqual(publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(publishers.cornerRadius.sinkCount, 1, "$cornerRadius should have been called once")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertEqual(publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_setValue_overflow() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.setValue(11.0)

        // THEN
        XCTAssertEqual(viewModel.value, 11.0, "Value should be updated to 2.40")
        XCTAssertEqual(viewModel.text, "11.0", "Text should reflect the new value")
        XCTAssertFalse(viewModel.isMinValue, "isMinValue should be false")
        XCTAssertTrue(viewModel.isMaxValue, "isMaxValue should be true")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertEqual(publishers.isMaxValue.sinkCount, 1, "$isMaxValue should have been called once")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_setValue_overflow_negative() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.setValue(-11.0)

        // THEN
        XCTAssertEqual(viewModel.value, -11.0, "Value should be updated to 2.40")
        XCTAssertEqual(viewModel.text, "-11.0", "Text should reflect the new value")
        XCTAssertTrue(viewModel.isMinValue, "isMinValue should be true")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false")

        // THEN - Publishers
        XCTAssertEqual(publishers.text.sinkCount, 1, "$text should have been called once")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertEqual(publishers.value.sinkCount, 1, "$value should have been called once")
    }

    func test_setValue_equalValue() {
        // GIVEN
        let initialValue: Double = 5.0
        let step: Double = 1.0
        let bounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: bounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.setValue(5.0)

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_didSet_bounds() {
        // GIVEN
        let initialValue: Double = 1.0
        let step: Double = 1.0
        let initialBounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: initialBounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.bounds = 2.0...8.0

        // THEN
        XCTAssertEqual(viewModel.value, 1.0, "Wrong value")
        XCTAssertEqual(viewModel.bounds, 2.0...8.0, "Bounds should be updated to 2.0...8.0")
        XCTAssertTrue(viewModel.isMinValue, "isMinValue should be true")
        XCTAssertFalse(viewModel.isMaxValue, "isMaxValue should be false")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertEqual(publishers.isMinValue.sinkCount, 1, "$isMinValue should have been called once")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }

    func test_didSet_bounds_equalValue() {
        // GIVEN
        let initialValue: Double = 1.0
        let step: Double = 1.0
        let initialBounds: ClosedRange<Double> = 0.0...10.0
        let viewModel = StepperControlViewModel(
            theme: self.theme,
            value: initialValue,
            step: step,
            in: initialBounds
        )
        let publishers = self.createPublishers(viewModel: viewModel)
        publishers.reset()

        // WHEN
        viewModel.bounds = 0.0...10.0

        // THEN
        XCTAssertEqual(viewModel.value, 1.0, "Wrong value")
        XCTAssertEqual(viewModel.bounds, 0.0...10.0, "Bounds shouldn't have changed")

        // THEN - Publishers
        XCTAssertFalse(publishers.text.sinkCalled, "$text should not have been called")
        XCTAssertFalse(publishers.textFont.sinkCalled, "$textFont should not have been called")
        XCTAssertFalse(publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(publishers.borderColor.sinkCalled, "$borderColor should not have been called")
        XCTAssertFalse(publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(publishers.cornerRadius.sinkCalled, "$cornerRadius should not have been called")
        XCTAssertFalse(publishers.isMinValue.sinkCalled, "$isMinValue should not have been called")
        XCTAssertFalse(publishers.isMaxValue.sinkCalled, "$isMaxValue should not have been called")
        XCTAssertFalse(publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(publishers.value.sinkCalled, "$value should not have been called")
    }
}

final class StepperPublishers<V> where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    var cancellables = Set<AnyCancellable>()

    var text: PublisherMock<Published<String>.Publisher>
    var textFont: PublisherMock<Published<any TypographyFontToken>.Publisher>
    var textColor: PublisherMock<Published<any ColorToken>.Publisher>
    var backgroundColor: PublisherMock<Published<any ColorToken>.Publisher>
    var borderColor: PublisherMock<Published<any ColorToken>.Publisher>
    var borderWidth: PublisherMock<Published<CGFloat>.Publisher>
    var cornerRadius: PublisherMock<Published<CGFloat>.Publisher>
    var isMinValue: PublisherMock<Published<Bool>.Publisher>
    var isMaxValue: PublisherMock<Published<Bool>.Publisher>
    var dim: PublisherMock<Published<CGFloat>.Publisher>
    var value: PublisherMock<Published<V>.Publisher>

    init(
        text: PublisherMock<Published<String>.Publisher>,
        textFont: PublisherMock<Published<any TypographyFontToken>.Publisher>,
        textColor: PublisherMock<Published<any ColorToken>.Publisher>,
        backgroundColor: PublisherMock<Published<any ColorToken>.Publisher>,
        borderColor: PublisherMock<Published<any ColorToken>.Publisher>,
        borderWidth: PublisherMock<Published<CGFloat>.Publisher>,
        cornerRadius: PublisherMock<Published<CGFloat>.Publisher>,
        isMinValue: PublisherMock<Published<Bool>.Publisher>,
        isMaxValue: PublisherMock<Published<Bool>.Publisher>,
        dim: PublisherMock<Published<CGFloat>.Publisher>,
        value: PublisherMock<Published<V>.Publisher>
    ) {
        self.text = text
        self.textFont = textFont
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.isMinValue = isMinValue
        self.isMaxValue = isMaxValue
        self.dim = dim
        self.value = value
    }

    func load() {
        self.cancellables = Set<AnyCancellable>()

        self.text.loadTesting(on: &self.cancellables)
        self.textFont.loadTesting(on: &self.cancellables)
        self.textColor.loadTesting(on: &self.cancellables)
        self.backgroundColor.loadTesting(on: &self.cancellables)
        self.borderColor.loadTesting(on: &self.cancellables)
        self.borderWidth.loadTesting(on: &self.cancellables)
        self.cornerRadius.loadTesting(on: &self.cancellables)
        self.isMinValue.loadTesting(on: &self.cancellables)
        self.isMaxValue.loadTesting(on: &self.cancellables)
        self.dim.loadTesting(on: &self.cancellables)
        self.value.loadTesting(on: &self.cancellables)
    }

    func reset() {
        self.text.reset()
        self.textFont.reset()
        self.textColor.reset()
        self.backgroundColor.reset()
        self.borderColor.reset()
        self.borderWidth.reset()
        self.cornerRadius.reset()
        self.isMinValue.reset()
        self.isMaxValue.reset()
        self.dim.reset()
        self.value.reset()
    }
}
