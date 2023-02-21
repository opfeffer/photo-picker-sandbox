//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Oliver Pfeffer on 2/21/23.
//

import PhotosUI
import UIKit

class ViewController: UIViewController, PHPickerViewControllerDelegate {
    private struct FileURLMissingUnexpectedlyError: Error { }

    private let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = .init(
            systemItem: .add,
            primaryAction: .init { [weak self] _ in self?.openMediaPicker() }
        )

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func openMediaPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0
        configuration.filter = .none
        configuration.preferredAssetRepresentationMode = .current
        if #available(iOS 15, *) {
            configuration.selection = .ordered
        }
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self

        present(pickerViewController, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        for itemProvider in results.map(\.itemProvider) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: itemProvider.registeredTypeIdentifiers.first!) { [weak self] url, error in
                print("[result]", url, error)

                DispatchQueue.main.async {
                    let message: String
                    if let url {
                        message = "✅ successfully loaded file representation at \(url)\n"
                    } else {
                        message = "❌ failed to load file representation with error=\(error ?? FileURLMissingUnexpectedlyError())\n"
                    }
                    self?.textView.text += message
                }
            }
        }
    }
}

