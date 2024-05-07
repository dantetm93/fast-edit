//
//  HomeScreen.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit

class HomeScreen: BaseScreen {

    @IBOutlet weak var buttonPickImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIAction()
    }
    
    private func setupUIAction() {
        self.buttonPickImage.makeSmoothRounded(corner: 10)
        self.buttonPickImage.onClick { _ in
            PhotoPickerManager.current.openImagePicker { pickedImg in
                NavigationCenter.openImgEditingScreen(original: pickedImg)
            }
        }
    }

}
