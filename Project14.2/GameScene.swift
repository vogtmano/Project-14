//
//  GameScene.swift
//  Project14.2
//
//  Created by Maks Vogtman on 17/11/2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var finalScore: SKLabelNode!
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode()
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.text = "Score: 0"
        gameScore.fontName = "Chalkduster"
        gameScore.fontSize = 48
        gameScore.horizontalAlignmentMode = .left
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + i * 170, y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + i * 170, y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + i * 170, y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + i * 170, y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            fire(box: whackSlot)
            
            if node.name == "charFriend" {
                score -= 5
                node.run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                score += 1
                node.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
                whackSlot.charNode.xScale = 0.75
                whackSlot.charNode.yScale = 0.75
            }
        }
    }
    
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            gameOver.run(SKAction.playSoundFileNamed("gameOver.caf", waitForCompletion: false))
            addChild(gameOver)
            
            showFinalScore()
            gameScore.isHidden = true
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    
    func showFinalScore() {
        finalScore = SKLabelNode()
        finalScore.position = CGPoint(x: 512, y: 260)
        finalScore.text = "Final score: \(score)"
        finalScore.fontName = "AvenirNext-Bold"
        finalScore.fontSize = 70
        finalScore.zPosition = 1
        addChild(finalScore)
    }
    
    
    func fire(box: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "fire.sks") {
            fireParticles.position = box.position
            fireParticles.zPosition = 1
            addChild(fireParticles)
        }
    }
}
