//
//  CircleShader.metal
//  SoundVisualizer
//
//  Created by 板垣智也 on 2021/12/04.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    vector_float4 position [[ position ]];
    vector_float4 color;
};

vertex VertexOut vertexShader(const constant vector_float2 *vertexArray [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    // fetch the current vertex we're on using the vid to index into our buffer data
    // which holds all of our vertex points that we passed in
    vector_float2 currentVertex = vertexArray[vid];
    VertexOut output;
    
    // populate the output position with the x and y values of our input vetex data
    output.position = vector_float4(currentVertex.x, currentVertex.y, 0, 1);
    // set of the color
    output.color =vector_float4(1, 1, 1, 1);
    
    return output;
}

fragment vector_float4 fragmentShader(VertexOut interpolated [[ stage_in ]]) {
    return interpolated.color;
}
