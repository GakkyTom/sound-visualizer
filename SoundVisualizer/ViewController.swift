//
//  ViewController.swift
//  SoundVisualizer
//
//  Created by 板垣智也 on 2021/12/04.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    @IBOutlet weak var metalCircleView: MTKView!
    
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    
    private var metalCommandQueue: MTLCommandQueue!
    private var renderPipeline: MTLRenderPipelineState!
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        metalCircleView.enableSetNeedsDisplay = true
        metalCircleView.setNeedsDisplay()
    }
    
    private func setupMetal() {
        metalCommandQueue = metalDevice.makeCommandQueue()
        metalCircleView.device = metalDevice
        metalCircleView.delegate = self
    }
}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("\(self.classForCoder)/" + #function)
    }
    
    func draw(in view: MTKView) {
        // Creating the commandBuffer for the queue
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              // Creating the intervace for the pipeline
              let renderDescriptor = view.currentRenderPassDescriptor
        else { return }
        
        // Setting a background color
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 0.5, 1)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor)
        else { return }
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        
        commandBuffer.commit()
    }
}
