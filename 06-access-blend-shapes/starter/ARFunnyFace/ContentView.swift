/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import ARKit
import SwiftUI
import RealityKit

var arView: ARView!

struct ContentView : View {
  @State var currentProp: Prop = .robot
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ARViewContainer(currentProp: $currentProp).edgesIgnoringSafeArea(.all)
      PropChooser(currentProp: $currentProp)
    }
  }
}

struct ARViewContainer: UIViewRepresentable {
  @Binding var currentProp: Prop
  
  func makeUIView(context: Context) -> ARView {
    arView = ARView(frame: .zero)
    arView.session.delegate = context.coordinator
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {
    uiView.scene.anchors.removeAll()
    
    let arConfiguration = ARFaceTrackingConfiguration()
    uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    
    var anchor: RealityKit.HasAnchoring
    switch currentProp {
    case .fancyHat:
      anchor = try! Experience.loadFancyHat()
    case .glasses:
      anchor = try! Experience.loadGlasses()
    case .mustache:
      anchor = try! Experience.loadMustache()
    case .eyeball:
      anchor = try! Experience.loadEyeball()
    case .robot:
      anchor = try! Experience.loadRobot()
    }
    uiView.scene.addAnchor(anchor)
  }
  
  func makeCoordinator() -> ARDelegateHandler {
    ARDelegateHandler(self)
  }
  
  class ARDelegateHandler: NSObject, ARSessionDelegate {
    
    var arViewContainer: ARViewContainer
    
    init(_ control: ARViewContainer) {
      arViewContainer = control
      super.init()
    }
    
    func eyeballLook(at point: simd_float3) {
      guard let eyeball = arView.scene.findEntity(named: "Eyeball")
      else { return }
      
      eyeball.look(at: point, from: eyeball.position, upVector: SIMD3<Float>(0, 1, -1), relativeTo: eyeball.parent)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
      guard let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else { return }
      eyeballLook(at: faceAnchor.lookAtPoint)
    }
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
