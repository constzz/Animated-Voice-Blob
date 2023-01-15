//
//  ViewControllerWithStackInScroll.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 05.01.2023.
//

import UIKit

public class ViewControllerWithStackInScroll: UIViewController {

  private(set) lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 0
    return stackView
  }()

  private(set) var scrollView = UIScrollView()

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    addSubviews()
    setupAutolayout()
  }
}

private extension ViewControllerWithStackInScroll {

  func addSubviews() {
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)
  }

  func setupAutolayout() {
    scrollView.prepareForAutoLayout()
    scrollView.pinToSuperView()

    stackView.prepareForAutoLayout()
    NSLayoutConstraint.activate([
      scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: stackView.widthAnchor),
      scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
      scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
    ])
  }
}

