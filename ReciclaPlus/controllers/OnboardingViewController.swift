//
//  OnboardingViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackViewDots: UIStackView!
    @IBOutlet weak var comencemosButton: UIButton!
    
    // Datos para los slides
    private var onboardingData: [OnboardingSlide] = []
    
    private var currentPage = 0
    private var dotViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        loadOnboardingFromAPI()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        // Configurar layout para scroll horizontal
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
        }
    }
    
    private func setupDots() {
        // Limpiar dots existentes
        stackViewDots.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        
        // Configurar el stack view
        stackViewDots.axis = .horizontal
        stackViewDots.distribution = .equalSpacing
        stackViewDots.alignment = .center
        stackViewDots.spacing = 8
        
        // Crear dots para cada slide
        for _ in 0..<onboardingData.count {
            let dot = createDot()
            stackViewDots.addArrangedSubview(dot)
            dotViews.append(dot)
        }
        
        updateDots()
    }
    
    private func createDot() -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
        dot.layer.cornerRadius = 5
        dot.backgroundColor = UIColor.lightGray
        return dot
    }
    
    private func updateDots() {
        for (index, dot) in stackViewDots.arrangedSubviews.enumerated() {
            dot.backgroundColor = index == currentPage ? UIColor.systemCyan : UIColor.lightGray
        }
    }
    
    private func updateButtonVisibility() {
        let isLastSlide = currentPage == onboardingData.count - 1
        comencemosButton.isHidden = !isLastSlide
    }
    
    @IBAction func comencemosButtonTapped(_ sender: UIButton) {
        // Navegación programática hacia la vista de login
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "BYZ-38-t0r") as? LoginViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            loginViewController.modalTransitionStyle = .coverVertical
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image Helper Methods
    
    /// Convierte rutas de imágenes de la API a nombres de archivos locales
    private func convertAPIImagePathToLocalName(_ apiImagePath: String) -> String {
        // Remover la barra inicial si existe
        let cleanPath = apiImagePath.hasPrefix("/") ? String(apiImagePath.dropFirst()) : apiImagePath
        
        // Mapear rutas específicas a nombres de archivos locales
        switch cleanPath {
        // Onboarding
        case let path where path.hasPrefix("onboarding/"):
            return String(path.dropFirst(11)) // Remover "onboarding/"
        
        // Fallback: usar el nombre del archivo sin la ruta
        default:
            return cleanPath.components(separatedBy: "/").last ?? "slide1_image"
        }
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCollectionViewCell
        let slide = onboardingData[indexPath.item]
        cell.configure(with: slide)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        let newPage = Int(pageIndex)
        
        // Solo actualizar si la página cambió
        if newPage != currentPage && newPage >= 0 && newPage < onboardingData.count {
            currentPage = newPage
            
            // Actualizar dots
            updateDots()
            
            // Mostrar/ocultar botón en el último slide
            updateButtonVisibility()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / pageWidth)
        updateDots()
        updateButtonVisibility()
    }
}

// MARK: - API Methods
extension OnboardingViewController {
    private func loadOnboardingFromAPI() {
        APIManager.shared.getOnboarding { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let onboardingSlides):
                    self?.onboardingData = onboardingSlides.map { slide in
                        OnboardingSlide(
                            image: self?.convertAPIImagePathToLocalName(slide.imagen) ?? "slide1_image",
                            title: slide.titulo,
                            description: slide.descripcion
                        )
                    }
                    self?.setupDots()
                    self?.updateButtonVisibility()
                    self?.collectionView.reloadData()
                case .failure(_):
                    // Keep onboardingData empty on error
                    self?.setupDots()
                    self?.updateButtonVisibility()
                }
            }
        }
    }
}

// MARK: - OnboardingSlide Model
struct OnboardingSlide {
    let image: String
    let title: String
    let description: String
}

// MARK: - OnboardingCollectionViewCell
class OnboardingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(with slide: OnboardingSlide) {
        imageView.image = UIImage(named: slide.image)
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }
}