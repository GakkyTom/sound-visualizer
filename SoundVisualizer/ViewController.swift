//
//  ViewController.swift
//  SoundVisualizer
//
//  Created by 板垣智也 on 2021/12/04.
//

import UIKit
import MetalKit
import simd

class ViewController: UIViewController {

    @IBOutlet weak var metalCircleView: MTKView!
    
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    
    private var metalCommandQueue: MTLCommandQueue!
    private var metalRenderPipelineState: MTLRenderPipelineState!
    
    private var circleVertices = [simd_float2]()
    private var vertexBuffer: MTLBuffer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createVertexPoints()

        setupMetal()
    }
    
    private func setupMetal() {
        metalCommandQueue = metalDevice.makeCommandQueue()
        metalCircleView.device = metalDevice
        metalCircleView.delegate = self
        
        createPipelineState()
        
        vertexBuffer = metalDevice.makeBuffer(bytes: circleVertices, length: circleVertices.count * MemoryLayout<simd_float2>.stride, options: [])!
        
        metalCircleView.enableSetNeedsDisplay = true
        metalCircleView.setNeedsDisplay()
    }
    
    private func createPipelineState() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        // finds the metal file from the main bundle
        let library = metalDevice.makeDefaultLibrary()!
        
        // give the names of the function to the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        // set the pixel format to match the MetalView's pixel format
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalCircleView.colorPixelFormat

        // https://developer.apple.com/forums/thread/99273
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        // make the pipelinestate using the GPU interface and the pipelineDescriptor
        metalRenderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func createVertexPoints() {
        func rads(forDegree d: Float) -> Float32 {
            return (Float.pi*d)/180
        }
        
        let origin = simd_float2(0, 0)
        
        for i in 0...720 {
            let position: simd_float2 = [cos(rads(forDegree: Float(Float(i)/2.0))),
                                         sin(rads(forDegree: Float(Float(i)/2.0)))]
            circleVertices.append(position)
            if (i + 1) % 2 == 0 {
                circleVertices.append(origin)
            }
        }
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
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1)

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor)
        else { return }
        
        // tell it swhat renderPipeline to use
        renderEncoder.setRenderPipelineState(metalRenderPipelineState)


        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1081)
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
