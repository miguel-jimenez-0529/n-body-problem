//
//  UniverseScene.swift
//  NBody
//
//  Created by Daniel Jilg on 14.04.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation
import SpriteKit

class UniverseScene: SKScene {
    let universe = Universe(initializer: RandomSolarInitializer(numberOfBodies: 42))
    private var bodyShapes = [SKShapeNode]()
    private var bodyLabels = [SKLabelNode]()
    private var lastUpdatedAt: TimeInterval?

    public var timeWarpFactor = 1e7
    public var drawTrails = true
    public var drawLabels = true
    public var selectionAlgorithm: SelectionAlgorithm = BruteForce()

    public var zoomFactor = 23e8

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        universe.selectionAlgorithm = selectionAlgorithm

        // Create Camera
        let cameraNode = SKCameraNode()
        addChild(cameraNode)
        cameraNode.setScale(1.2)
        camera = cameraNode

        // Create Shapes
        for body in universe.bodies {
            createNodes(for: body)
        }
    }

    private func createNodes(for body: Body) {
        var bodyShape: SKShapeNode?

        // Configure Shape
        if let planetoid = body as? Planetoid {
            let radius: CGFloat = max(CGFloat(planetoid.radius * 64 / zoomFactor), 2)
            bodyShape = SKShapeNode(circleOfRadius: radius)
        } else {
            bodyShape = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        }

        bodyShape!.fillColor = body.color
        bodyShapes.append(bodyShape!)
        addChild(bodyShape!)

        // Configure Trail
        if let emitter = SKEmitterNode(fileNamed: "TrailParticle.sks"), drawTrails {
            emitter.targetNode = self
            emitter.particleColor = body.color
            bodyShape?.addChild(emitter)
        }

        // Configure Label
        let bodyLabel = SKLabelNode(text: body.name)
        bodyLabel.fontColor = body.color
        bodyLabels.append(bodyLabel)
        addChild(bodyLabel)
    }

    override func update(_ currentTime: TimeInterval) {
        updateUniverseStatus(currentTime)
        updateUniverseDisplay()

        lastUpdatedAt = currentTime
    }

    fileprivate func updateUniverseDisplay() {
        for index in 0..<universe.bodies.count {
            let body = universe.bodies[index]
            let bodyShape = bodyShapes[index]
            let bodyLabel = bodyLabels[index]

            // Update Shape
            bodyShape.position = CGPoint(
                x: body.position.x / zoomFactor,
                y: body.position.y / zoomFactor
            )

            // Update Label
            bodyLabel.position = CGPoint(x: bodyShape.position.x, y: bodyShape.position.y - (30 + (bodyShape.path?.boundingBox.height ?? 10) / 2))
            bodyLabel.text = body.name
            bodyLabel.fontColor = drawLabels ? body.color : NSColor.clear
        }
    }

    fileprivate func updateUniverseStatus(_ currentTime: TimeInterval) {
        if let lastUpdatedAt = lastUpdatedAt {
            let elapsedTime = currentTime - lastUpdatedAt
            universe.update(elapsedTime: elapsedTime * timeWarpFactor)
        }
    }


}
