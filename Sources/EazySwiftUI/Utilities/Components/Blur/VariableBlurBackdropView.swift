//
//  VariableBlurBackdropView.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
import UIKit

/// The `UIVisualEffectView` host that owns the blur filter and dimming gradient.
///
/// `UIVisualEffectView` can rebuild its internal hierarchy across window and
/// trait changes. Subview references are therefore weak and resolved again
/// during layout rather than captured once.
final class VariableBlurBackdropView: UIView {
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    private var edge: VariableBlurEdge = .top
    private var maxRadius: CGFloat = 4
    private var plateau: CGFloat = 0
    private var dimmingColor: UIColor?
    private var dimmingLightAlpha: CGFloat = 0
    private var dimmingDarkAlpha: CGFloat = 0
    private var dimmingOvershoot: CGFloat = 1
    private var fallbackStyle: UIBlurEffect.Style = .systemUltraThinMaterial

    private var dimmingView: UIImageView?
    private var blurMask: CGImage?
    private var blurMaskLength = 0
    private var dimmingLength = 0
    private weak var backdropView: UIView?
    private weak var overlayView: UIView?
    private var appliedFilter: FilterSignature?

    private var supportsVariableBlur: Bool {
        BlurFilterProvider.isSupported
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = false
        addSubview(effectView)

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (view: VariableBlurBackdropView, _: UITraitCollection) in
            view.invalidateEffectViewHierarchy()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        invalidateEffectViewHierarchy()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = bounds
        refreshGradientsIfNeeded()
        applyEffect()
        layoutDimmingView()
    }

    /// Applies every parameter in one pass, rebuilding only what changed.
    func configure(
        edge: VariableBlurEdge,
        maxRadius: CGFloat,
        plateau: CGFloat,
        dimmingColor: UIColor?,
        dimmingLightAlpha: CGFloat,
        dimmingDarkAlpha: CGFloat,
        dimmingOvershoot: CGFloat,
        fallbackStyle: UIBlurEffect.Style
    ) {
        let maxRadius = Self.finiteNonnegative(maxRadius)
        let plateau = Self.unitValue(plateau)
        let dimmingLightAlpha = Self.unitValue(dimmingLightAlpha)
        let dimmingDarkAlpha = Self.unitValue(dimmingDarkAlpha)
        let dimmingOvershoot = Self.finiteNonnegative(dimmingOvershoot)

        let blurChanged = edge != self.edge
            || maxRadius != self.maxRadius
            || plateau != self.plateau
        let dimmingChanged = edge != self.edge
            || dimmingColor != self.dimmingColor
            || dimmingOvershoot != self.dimmingOvershoot

        self.edge = edge
        self.maxRadius = maxRadius
        self.plateau = plateau
        self.dimmingColor = dimmingColor
        self.dimmingLightAlpha = dimmingLightAlpha
        self.dimmingDarkAlpha = dimmingDarkAlpha
        self.dimmingOvershoot = dimmingOvershoot
        self.fallbackStyle = fallbackStyle

        if blurChanged {
            blurMask = nil
            blurMaskLength = 0
        }
        if dimmingChanged {
            dimmingView?.image = nil
            dimmingLength = 0
        }
        setNeedsLayout()
    }

    private func invalidateEffectViewHierarchy() {
        backdropView = nil
        overlayView = nil
        appliedFilter = nil
        setNeedsLayout()
    }

    private func applyEffect() {
        guard supportsVariableBlur else {
            applyFallback()
            return
        }

        if overlayView == nil {
            overlayView = BlurFilterProvider.subview(
                of: effectView,
                withClassNameContaining: "subview"
            )
        }
        // The overlay is the light/dark wash that makes a material frosted. A
        // transparent blur needs only the backdrop filter.
        overlayView?.isHidden = true

        if backdropView == nil {
            backdropView = BlurFilterProvider.subview(
                of: effectView,
                withClassNameContaining: "backdrop"
            )
        }
        guard let backdropView, let blurMask else { return }

        let signature = FilterSignature(
            radius: maxRadius,
            maskLength: blurMaskLength,
            plateau: plateau,
            edge: edge,
            backdrop: ObjectIdentifier(backdropView)
        )
        let isMissing = backdropView.layer.filters?.isEmpty ?? true
        guard signature != appliedFilter || isMissing else { return }

        guard let filter = BlurFilterProvider.makeFilter(named: "variableBlur") else {
            applyFallback()
            return
        }
        filter.setValue(blurMask, forKey: "inputMaskImage")
        filter.setValue(maxRadius, forKey: "inputRadius")
        filter.setValue(true, forKey: "inputNormalizeEdges")

        backdropView.layer.filters = [filter]
        // Rendering an already blurred surface at three-quarter resolution
        // reduces the cost without a visible loss in this backdrop.
        backdropView.layer.setValue(0.75, forKey: "scale")
        appliedFilter = signature
    }

    private func applyFallback() {
        let expectedEffect = UIBlurEffect(style: fallbackStyle)
        if effectView.effect != expectedEffect {
            effectView.effect = expectedEffect
        }
        overlayView?.isHidden = false
    }

    private func refreshGradientsIfNeeded() {
        guard bounds.height > 0, bounds.width > 0 else { return }

        let length = Int(bounds.height.rounded(.up))
        if blurMask == nil || blurMaskLength != length {
            blurMask = BlurGradientMask.ramp(
                length: length,
                edge: edge,
                plateau: plateau,
                eased: false
            )
            blurMaskLength = length
            appliedFilter = nil
        }

        guard dimmingColor != nil else {
            dimmingView?.removeFromSuperview()
            dimmingView = nil
            dimmingLength = 0
            return
        }

        let dimmedLength = Int((bounds.height * dimmingOvershoot).rounded(.up))
        let view = dimmingViewIfNeeded()
        view.tintColor = dimmingColor
        if view.image == nil || dimmingLength != dimmedLength {
            let ramp = BlurGradientMask.ramp(
                length: dimmedLength,
                edge: edge,
                plateau: 0,
                eased: true
            )
            view.image = ramp.map {
                UIImage(cgImage: $0).withRenderingMode(.alwaysTemplate)
            }
            dimmingLength = dimmedLength
        }
    }

    private func dimmingViewIfNeeded() -> UIImageView {
        if let dimmingView {
            return dimmingView
        }

        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleToFill
        addSubview(view)
        dimmingView = view
        return view
    }

    private func layoutDimmingView() {
        guard let dimmingView else { return }
        let height = bounds.height * dimmingOvershoot
        dimmingView.frame = CGRect(
            x: 0,
            y: edge == .top ? 0 : bounds.height - height,
            width: bounds.width,
            height: height
        )
        dimmingView.alpha = traitCollection.userInterfaceStyle == .dark
            ? dimmingDarkAlpha
            : dimmingLightAlpha
    }

    private static func finiteNonnegative(_ value: CGFloat) -> CGFloat {
        value.isFinite ? max(value, 0) : 0
    }

    private static func unitValue(_ value: CGFloat) -> CGFloat {
        value.isFinite ? min(max(value, 0), 1) : 0
    }
}

private extension VariableBlurBackdropView {
    struct FilterSignature: Equatable {
        var radius: CGFloat
        var maskLength: Int
        var plateau: CGFloat
        var edge: VariableBlurEdge
        var backdrop: ObjectIdentifier?
    }
}
#endif
