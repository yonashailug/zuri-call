import FirebaseAuth
import FirebaseCore
import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    for context in URLContexts {
      if Auth.auth().canHandle(context.url) {
        return
      }
    }

    super.scene(scene, openURLContexts: URLContexts)
  }
}
