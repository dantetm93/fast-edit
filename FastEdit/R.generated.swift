//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import RswiftResources
import UIKit

private class BundleFinder {}
let R = _R(bundle: Bundle(for: BundleFinder.self))

struct _R {
  let bundle: Foundation.Bundle

  let reuseIdentifier = reuseIdentifier()

  var image: image { .init(bundle: bundle) }
  var info: info { .init(bundle: bundle) }
  var nib: nib { .init(bundle: bundle) }
  var storyboard: storyboard { .init(bundle: bundle) }

  func image(bundle: Foundation.Bundle) -> image {
    .init(bundle: bundle)
  }
  func info(bundle: Foundation.Bundle) -> info {
    .init(bundle: bundle)
  }
  func nib(bundle: Foundation.Bundle) -> nib {
    .init(bundle: bundle)
  }
  func storyboard(bundle: Foundation.Bundle) -> storyboard {
    .init(bundle: bundle)
  }
  func validate() throws {
    try self.nib.validate()
    try self.storyboard.validate()
  }

  struct project {
    let developmentRegion = "en"
  }

  /// This `_R.image` struct is generated, and contains static references to 21 images.
  struct image {
    let bundle: Foundation.Bundle

    /// Image `appstore`.
    var appstore: RswiftResources.ImageResource { .init(name: "appstore", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `ic_gallery`.
    var ic_gallery: RswiftResources.ImageResource { .init(name: "ic_gallery", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `ic_notification`.
    var ic_notification: RswiftResources.ImageResource { .init(name: "ic_notification", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `ic_video_recording`.
    var ic_video_recording: RswiftResources.ImageResource { .init(name: "ic_video_recording", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `ic_voice_recording`.
    var ic_voice_recording: RswiftResources.ImageResource { .init(name: "ic_voice_recording", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_back`.
    var icon_back: RswiftResources.ImageResource { .init(name: "icon_back", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_brightness`.
    var icon_brightness: RswiftResources.ImageResource { .init(name: "icon_brightness", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_constrast`.
    var icon_constrast: RswiftResources.ImageResource { .init(name: "icon_constrast", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_cut`.
    var icon_cut: RswiftResources.ImageResource { .init(name: "icon_cut", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_eraser`.
    var icon_eraser: RswiftResources.ImageResource { .init(name: "icon_eraser", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_exposure`.
    var icon_exposure: RswiftResources.ImageResource { .init(name: "icon_exposure", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_hand_rorate`.
    var icon_hand_rorate: RswiftResources.ImageResource { .init(name: "icon_hand_rorate", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_redo`.
    var icon_redo: RswiftResources.ImageResource { .init(name: "icon_redo", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_rotate`.
    var icon_rotate: RswiftResources.ImageResource { .init(name: "icon_rotate", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_rotate_left`.
    var icon_rotate_left: RswiftResources.ImageResource { .init(name: "icon_rotate_left", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_rotate_right`.
    var icon_rotate_right: RswiftResources.ImageResource { .init(name: "icon_rotate_right", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_saturation`.
    var icon_saturation: RswiftResources.ImageResource { .init(name: "icon_saturation", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_save`.
    var icon_save: RswiftResources.ImageResource { .init(name: "icon_save", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_temperature`.
    var icon_temperature: RswiftResources.ImageResource { .init(name: "icon_temperature", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `icon_undo`.
    var icon_undo: RswiftResources.ImageResource { .init(name: "icon_undo", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `img_home`.
    var img_home: RswiftResources.ImageResource { .init(name: "img_home", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }
  }

  /// This `_R.info` struct is generated, and contains static references to 1 properties.
  struct info {
    let bundle: Foundation.Bundle
    var uiApplicationSceneManifest: uiApplicationSceneManifest { .init(bundle: bundle) }

    func uiApplicationSceneManifest(bundle: Foundation.Bundle) -> uiApplicationSceneManifest {
      .init(bundle: bundle)
    }

    struct uiApplicationSceneManifest {
      let bundle: Foundation.Bundle

      let uiApplicationSupportsMultipleScenes: Bool = false

      var _key: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest"], key: "_key") ?? "UIApplicationSceneManifest" }
      var uiSceneConfigurations: uiSceneConfigurations { .init(bundle: bundle) }

      func uiSceneConfigurations(bundle: Foundation.Bundle) -> uiSceneConfigurations {
        .init(bundle: bundle)
      }

      struct uiSceneConfigurations {
        let bundle: Foundation.Bundle
        var _key: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest", "UISceneConfigurations"], key: "_key") ?? "UISceneConfigurations" }
        var uiWindowSceneSessionRoleApplication: uiWindowSceneSessionRoleApplication { .init(bundle: bundle) }

        func uiWindowSceneSessionRoleApplication(bundle: Foundation.Bundle) -> uiWindowSceneSessionRoleApplication {
          .init(bundle: bundle)
        }

        struct uiWindowSceneSessionRoleApplication {
          let bundle: Foundation.Bundle
          var defaultConfiguration: defaultConfiguration { .init(bundle: bundle) }

          func defaultConfiguration(bundle: Foundation.Bundle) -> defaultConfiguration {
            .init(bundle: bundle)
          }

          struct defaultConfiguration {
            let bundle: Foundation.Bundle
            var uiSceneConfigurationName: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication"], key: "UISceneConfigurationName") ?? "Default Configuration" }
            var uiSceneDelegateClassName: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication"], key: "UISceneDelegateClassName") ?? "$(PRODUCT_MODULE_NAME).SceneDelegate" }
          }
        }
      }
    }
  }

  /// This `_R.nib` struct is generated, and contains static references to 5 nibs.
  struct nib {
    let bundle: Foundation.Bundle

    /// Nib `EditingToolCollectionCell`.
    var editingToolCollectionCell: RswiftResources.NibReferenceReuseIdentifier<EditingToolCollectionCell, EditingToolCollectionCell> { .init(name: "EditingToolCollectionCell", bundle: bundle, identifier: "EditingToolCollectionCell") }

    /// Nib `HomeScreen`.
    var homeScreen: RswiftResources.NibReference<UIKit.UIView> { .init(name: "HomeScreen", bundle: bundle) }

    /// Nib `ImgEditingScreen`.
    var imgEditingScreen: RswiftResources.NibReference<UIKit.UIView> { .init(name: "ImgEditingScreen", bundle: bundle) }

    /// Nib `PermissionDialogScreen`.
    var permissionDialogScreen: RswiftResources.NibReference<UIKit.UIView> { .init(name: "PermissionDialogScreen", bundle: bundle) }

    /// Nib `SplashScreen`.
    var splashScreen: RswiftResources.NibReference<UIKit.UIView> { .init(name: "SplashScreen", bundle: bundle) }

    func validate() throws {
      if UIKit.UIImage(named: "img_home", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'img_home' is used in nib 'HomeScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_back", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_back' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_eraser", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_eraser' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_redo", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_redo' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_rotate_left", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_rotate_left' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_rotate_right", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_rotate_right' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_save", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_save' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "icon_undo", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'icon_undo' is used in nib 'ImgEditingScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "ic_gallery", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'ic_gallery' is used in nib 'PermissionDialogScreen', but couldn't be loaded.") }
      if UIKit.UIImage(named: "appstore", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'appstore' is used in nib 'SplashScreen', but couldn't be loaded.") }
    }
  }

  /// This `_R.reuseIdentifier` struct is generated, and contains static references to 1 reuse identifiers.
  struct reuseIdentifier {

    /// Reuse identifier `EditingToolCollectionCell`.
    let editingToolCollectionCell: RswiftResources.ReuseIdentifier<EditingToolCollectionCell> = .init(identifier: "EditingToolCollectionCell")
  }

  /// This `_R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    let bundle: Foundation.Bundle
    var launchScreen: launchScreen { .init(bundle: bundle) }

    func launchScreen(bundle: Foundation.Bundle) -> launchScreen {
      .init(bundle: bundle)
    }
    func validate() throws {
      try self.launchScreen.validate()
    }


    /// Storyboard `LaunchScreen`.
    struct launchScreen: RswiftResources.StoryboardReference, RswiftResources.InitialControllerContainer {
      typealias InitialController = UIKit.UIViewController

      let bundle: Foundation.Bundle

      let name = "LaunchScreen"
      func validate() throws {
        if UIKit.UIImage(named: "appstore", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'appstore' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
      }
    }
  }
}