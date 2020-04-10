//
//  ViewController.swift
//  SampleARVRApp
//
//  Created by Jaya on 06/04/20.
//  Copyright © 2020 Jaya. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    //MARK: - Variables
    private let configuration = ARWorldTrackingConfiguration()
    private var node: SCNNode!
    private var lastRotation: Float = 0
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
       // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.addTapGesture()
        self.addPinchGesture()
        self.addRotationGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    //MARK: - Methods
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        //1 Float = 1 meter.
        let colors = [UIColor.green, // front
            UIColor.red, // right
            UIColor.blue, // back
            UIColor.yellow, // left
            UIColor.purple, // top
            UIColor.gray] // bottom
        
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        
        box.materials = sideMaterials
        
        self.node = SCNNode()
        self.node.geometry = box
        self.node.position = SCNVector3(x, y, z)
        //Positive x is to the right. Negative x is to the left. Positive y is up. Negative y is down. Positive z is backward. Negative z is forward.
        //A node represents the position and the coordinates of an object in a 3D space. By itself, the node has no visible content.
        
        sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTap(_ gesture: UIPanGestureRecognizer) {
        let tapLocation = gesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(tapLocation, types: .featurePoint)
        
        guard let result = results.first else {
            return
        }
        
        let translation = result.worldTransform.translation
        
        guard let node = self.node else {
            self.addBox(x: translation.x, y: translation.y, z: translation.z)
            return
        }
        node.position = SCNVector3Make(translation.x, translation.y, translation.z)
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    private func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        self.sceneView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
         guard let node = self.node else {
            return
            }
        let originalScale = node.scale
        
        switch gesture.state {
        case .began:
            gesture.scale = CGFloat(originalScale.x)
        case .changed:
            var newScale: SCNVector3
            if gesture.scale < 0.5 {
                newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            } else if gesture.scale > 3 {
                newScale = SCNVector3(3, 3, 3)
            } else {
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            node.scale = newScale
        default:
            break
        }
    }
    
    private func addRotationGesture() {
        let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        self.sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .changed:
            // change node y angel
            self.node.eulerAngles.y = self.lastRotation + Float(gesture.rotation)
        case .ended:
            // save last rotation
            self.lastRotation += Float(gesture.rotation)
        default:
            break
        }
    }

}

extension float4x4 {
    var translation:  SIMD3<Float> {
        let translation = self.columns.3
        return  SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}
