//
//  OverlayView.swift
//  ReciclaPlus
//
//  Created by Assistant on $(date)
//

import UIKit

class OverlayView: UIView {
    
    // MARK: - UI Components
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var parentView: UIView?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add background view
        addSubview(backgroundView)
        
        // Add container view
        addSubview(containerView)
        
        setupConstraints()
        setupGestures()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background view constraints (full screen)
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container view constraints (centered)
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func setupGestures() {
        // Tap gesture to dismiss when tapping background
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    func show(in parentView: UIView) {
        self.parentView = parentView
        
        // Add to parent view
        parentView.addSubview(self)
        
        // Set constraints to fill parent view
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        
        // Animate appearance
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func addContentView(_ contentView: UIView) {
        // Remove any existing content
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add new content
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentView)
        
        // Set constraints for content view
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func updateContainerSize(width: CGFloat, height: CGFloat) {
        // Remove existing size constraints
        containerView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        // Add new size constraints
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: width),
            containerView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        dismiss()
    }
}

// MARK: - Convenience Methods
extension OverlayView {
    
    static func showEmpty(in parentView: UIView) -> OverlayView {
        let overlay = OverlayView()
        overlay.show(in: parentView)
        return overlay
    }
    
    static func showWithContent(_ contentView: UIView, in parentView: UIView, size: CGSize = CGSize(width: 300, height: 200)) -> OverlayView {
        let overlay = OverlayView()
        overlay.updateContainerSize(width: size.width, height: size.height)
        overlay.addContentView(contentView)
        overlay.show(in: parentView)
        return overlay
    }
}