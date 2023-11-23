//
//  WriteViewController.swift
//  Macro
//
//  Created by Byeon jinha on 11/20/23.
//

import Combine
import NMapsMap
import PhotosUI
import UIKit

final class WriteViewController: TabViewController {
    
    // MARK: - Properties
    
    private let viewModel: WriteViewModel
    private let const = MacroCarouselView.Const(itemSize: CGSize(width: 300, height: 340), itemSpacing: 24.0)
    private let imageAddSbuject: PassthroughSubject<Bool, Never> = .init()
    private let inputSubject: PassthroughSubject<WriteViewModel.Input, Never> = .init()
    private var photoAuthorizationStatus =  CurrentValueSubject<PHAuthorizationStatus, Never>(.notDetermined)
    private var subscriptions: Set<AnyCancellable> = []
    
    lazy var picker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let scrollContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let isVisibilityButton: UIButton = {
        let button = UIButton()
        let image = UIImage.appImage(.lockFill)?.withTintColor(UIColor.appColor(.statusRed), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(isisVisibilityButtonTouched), for: .touchUpInside)
        return button
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "제목을 입력하세요..."
        textField.font = UIFont.appFont(.baeEunBody)
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var carouselView: MacroCarouselView = {
        let view = MacroCarouselView(const: const, viewType: .write, outputSubject: imageAddSbuject)
        return view
    }()
    
    private let imageDescriptionTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "문구를 입력하세요"
        textField.font = UIFont.appFont(.baeEunBody)
        return textField
    }()
    
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.positionMode = .normal
        return mapView
    }()
    
    private let writeSubmitButton: UIButton = {
        let button = UIButton()
        let image = UIImage.appImage(.appLogo)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.appColor(.statusGreen)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(writeSubmitButtonTouched), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bind()
    }
    
    // MARK: - Init
    
    init(viewModel: WriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Settings

private extension WriteViewController {
    
    func setLayout() {
        titleTextField.rightView = isVisibilityButton
        view.backgroundColor = .white
        
        setTranslatesAutoresizingMaskIntoConstraints()
        addsubviews()
        setLayoutConstraints()
    }
    
    func setTranslatesAutoresizingMaskIntoConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        imageDescriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        writeSubmitButton.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addsubviews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        [
            titleTextField,
            carouselView,
            imageDescriptionTextField,
            mapView,
            writeSubmitButton
        ].forEach { self.scrollContentView.addSubview($0) }
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            carouselView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            carouselView.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor),
            carouselView.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor),
            carouselView.heightAnchor.constraint(equalToConstant: const.itemSize.height),
            
            imageDescriptionTextField.topAnchor.constraint(equalTo: carouselView.bottomAnchor, constant: 30),
            imageDescriptionTextField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 50),
            imageDescriptionTextField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -50),
            imageDescriptionTextField.heightAnchor.constraint(equalToConstant: 50),

            mapView.topAnchor.constraint(equalTo: imageDescriptionTextField.bottomAnchor, constant: 30),
            mapView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 24),
            mapView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -24),
            mapView.heightAnchor.constraint(equalToConstant: UIScreen.width - 48),
            
            writeSubmitButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 30),
            writeSubmitButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -30),
            writeSubmitButton.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            writeSubmitButton.widthAnchor.constraint(equalToConstant: UIScreen.width - 40),
            writeSubmitButton.heightAnchor.constraint(equalToConstant: 50),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
        ])
    }
}

// MARK: - Bind

private extension WriteViewController {
    func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case let .isVisibilityToggle(isVisibility):
                    let image = (isVisibility ? UIImage.appImage(.lockOpenFill) : UIImage.appImage(.lockFill))?.withTintColor(isVisibility ? UIColor.appColor(.statusGreen) : UIColor.appColor(.statusRed), renderingMode: .alwaysOriginal)
                    self?.isVisibilityButton.setImage(image, for: .normal)
                case let .outputImageData(imageDatas):
                    var images = [UIImage?]()
                    
                    imageDatas.forEach {
                        images.append(UIImage(data: $0))
                    }
                    
                    self?.carouselView.updateData(images)
                case .uploadWrite:
                    // TODO: - Home화면으로 돌아가
                    break
                }
            }
            .store(in: &subscriptions)
        
        imageAddSbuject
            .sink { buttonTouched in
                self.imageAddButtonTouched()
            }
            .store(in: &subscriptions)
        
        photoAuthorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .authorized:
                    self?.addImagePresent()
                default:
                    self?.photoAuthorizationRequest()
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - objc

private extension WriteViewController {
    @objc func isisVisibilityButtonTouched() {
        inputSubject.send(.isVisibilityButtonTouched)
    }
    
    @objc func writeSubmitButtonTouched() {
        inputSubject.send(.writeSubmit)
    }
}

// MARK: - Image Picker

extension WriteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            debugPrint("Image Pick results is Empyt")
            return
        }
        
        let itemProvider = results.first?.itemProvider
        
        var images = [UIImage?]()
        
        if let resultItempProvider = results.first?.itemProvider,
           resultItempProvider.canLoadObject(ofClass: UIImage.self) {
            resultItempProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let error {
                    debugPrint("Error loading image: \(error.localizedDescription)")
                }
                
                if let image = image as? UIImage, let data = image.jpegData(compressionQuality: 1.0) {
                    self?.inputSubject.send(.addImageData(imageData: data))
                }
            }
        }
    }
    
    func imageAddButtonTouched() {
        self.photoAuthorizationStatus.value = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    /// 사용자에게 라이브러리 접근 권한 요청 Method
    private func photoAuthorizationRequest() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
            self.photoAuthorizationStatus.value = newStatus
        }
    }
    
    /// Image Picker 나타나게 하는 Method
    private func addImagePresent() {
        DispatchQueue.main.async {
            self.present(self.picker, animated: true)
        }
    }
}
