- OOLONG: An MLIR-based Compiler Toolkit for GPU Dispatch
- or "How We'll Steal the GPU Back from the AI Guys"

Ivan Ho
First Year Report

----

10000 word limit

maybe a cheeky image of Gru holding up the GPU

# Introduction

It has been about 22 years since the raster pipeline of the GPU was first used for general compute, sparking off a worldwide, multi-decade, multi-trillion dollar investment into accelerating linear algebra on hardware initially designed for entertainment. With the advent of artificial intelligence, the majority of the research effort has largely been directed towards generalizing the rendering hardware such that it is more usable by generic compute workflows. Even so hardware accelerators and pipelines designed specifically for cmputer graphics, such as texture samplers and ray tracing acceleration structures, remain accessible on consumer-grade hardware across all vendors, begging to be exploited.

Therefore, the end goal of this thesis will be to create a high-level compiler toolkit for dispatching work to the GPU, allowing the user to utilize all three of the architectural pipelines available. Research will be focused on the workflows that are able to exploit cross-pipeline interactions by using accelerators designed for one domain in another. As the program dispatch will be split across different pipelines, the toolkit will be designed using MLIR, a multi-level compiler toolkit which separates program semantics into different dialects. This permits separation of concerns when deciding between optimizing the computation or the underlying pipelines that the computation would be dispatched to, and drastically limits the search space required for us to perform whole-program optimization. We dub this toolkit "Oolong", named after a type of tea to represent computer graphics's epytomous Utah teapot whose name also contains the Chinese character for dragon ("long") to represent compilers.

# Literature Review

## The GPU and General Purpose Compute

The GPU is a SIMD (Single Instruction, Multiple Data) architecture containing many streaming multiprocessors (SMs) that each execute a single instruction across multiple lanes conditionally. Programs written for the GPU, also known as "kernels", are issued in groups of thread blocks, which are each issued to an SM. Thread blocks are split into warps.

## Compilers for the GPU

Compilers for parallel programs readily take advantage of the GPU, which is designed to be a massively parallel processor.

Polyhedral compilers describe integer loops and tensors as polyhedra bounded by integer panes. Such programs are known as static control parts, or SCoPs. In polyhedral compilers, affine expressions on loop induction variables allow optimization problems to be solved with Presburger solvers. Additionally, loop transformations can be described as affine transformations of induction variables, which allows the framework that transforms the code to also verify it. To fit within the GPU's memory limitations, loop tiling allows the partitioning of SCoPs such that the memory accessed by each subtile would fit within the hardware's memory.

User-scheduled languages refer to programming languages which require writing two programs: a payload program that specifies the computation of the program, and a transform program that optimizes and transforms the payload program. The latter is also more commonly referred to as a 'schedule' that is user-specified. Halide, TVM, and ELEVATE are the most commonly cited examples of user-scheduled languages, each targeting different domains from image processing to machine learning.

LLVM's MLIR is also home to its own user-scheduled language, the Transform Dialect. However, MLIR's true innovation draws from its multi-level dialect representation, which encapsulates semantics at each individual.
<!-- some MLIR code should go here right -->
 
### MLIR

- Within MLIR, there are a variety of frameworks as well
    - StableHLO, IREE, Triton
    - IREE in particular has the Stream dialect

## The GPU and Processing Graphics

As we saw with general compute, the GPU has come a long way from being a fixed-function pipeline, manually plugging in transformation matrices and lights to draw to the screen texture. However, the vast majority of consumer grade GPUs are designed for exactly what it is named for: graphics processing. The compute pipeline, while most general, is far from the only pipeline available on the GPU. There are actually two other pipelines dedicated to graphics rendering available:

- Rasterization pipeline
- Raytracing pipeline

### The Rasterization Pipeline

Optimizations in the rasterized pipeline take aim at reducing overdraw.

However, the common complaint with deferred shading is that the intermediate textures that are materialized, also known as the G-Buffer or geometry buffer, is incredibly taxing on the GPU. Therefore, just like in the compute pipeline, the solution is to tile the G-Buffer to reduce the cost of the intermediates, which is known as tiled deferred shading. Just tiling the initial graphics pipeline alone has been found to yield significant returns, a technique known as Forward+. The key difference when it comes to tiling a pipeline, however, is that not only does the dispatch need to be tiled, but so does the geometry.

In general, we observe that a wide variety of techniques observed in optimizing compute can also be applied to rasterization.

### The Raytracing Pipeline

Despite having accelerators on the hardware dedicated to raytracing, however, real-time raytracing at full display resolution remains infeasible. To resolve this, all three GPU vendors provide a form of neural upscaling (Nvidia has DLSS, AMD has FSR, and Intel has XeSS), allowing rendering engines to render at a lower resolution (rendering at 960x540 for a 1920x1080 display) that is then upscaled to the target resolution by a neural network at constant-time cost.

## Rendering 

Offline rendering
- Compute-based raytracing workflows [Taichi]
- Inverse rendering [Mitsuba]

Unless you are writing a game engine, there's been very little research in optimizing rasterized pipelines

- Temporal locality: What can we use from the previous frame?
    - Unlike offline rendering workflows, real-time rendering is stateful. What questions can we ask about the semantics of that?
    - Consider CIRCT's loops, or Lustre's reactive programming

When doing computer graphics, there are three types of sematics to consider:
- The rendering equation (Lumen)
- The geometry of the scene (Nanite)
- The pipeline semantics (Unreal RHI)

DSL for real-time rendering:
- Luisarenderer?

# Progress Report 

This first year was spent investigating MLIR and its uses in the GPU. We attach the paper here.

# Thesis Proposal 

Perhaps the nagging question, of course, is "why hasn't anyone tried this?". Perhaps:
- The question doesn't yield interesting answers

## Where to Start

From what I have written, there are two concrete paper ideas to explore going into 2026.

- Rasterization Pipeline Optimizations are Program Rewrites
    - Deferred, Tiled Deferred, Forward+

### Rasterization Pipeline Optimizations are Program Rewrites


### Accelerating Sparse-Sparse Matrix Multiplication with Raytracing Hardware
The use of the TLAS/BLAS hardware to accelerate sparse matrix multipication.

Where dense linear algebra is polyhedral, we observe that sparse linear algebra exhibits some geometric aspects as well. Our goal is to increase the performance of block sparse-sparse matrix multiplication using compilers.

    - Dammit I got beaten https://dl.acm.org/doi/10.1145/3695053.3731072
        - They use CUDA/OptiX. Let's try using Vulkan instead?
        - Maybe we can further optimize, as OptiX is optimized for actual ray tracing workflows as opposed to pseudo-ray tracing workflows
            - The insight to find: what does optix do that is too rendering specific?
        - eg. Thread Reordering https://developer.nvidia.com/sites/default/files/akamai/gameworks/ser-whitepaper.pdf
            You want to reorder the threads such that adjacent computes are near each other.
        - Or we can research block-sparse matrices (and perform ray-traced intersections on blocks instead), and then performing the block-level computation in a compute shader

Both papers will motivate the construction of the generic GPU toolkit and dialect throughout the various years.
The fuzzy long-term goal for a 2027 paper would be every graphics grad student's white whale: building Unreal Engine's Nanite.
Obviously this is likely to change.

## Initial Compiler Design

Motivating Example:
- Deferred Shading -> Tiled Deferred Shadingx

Optimization of compute is about optimizing the computation:
- Tiling it
Optimization of rendering is about optimizing the rendering:
- Baking
- Culling

Other trivial things that should work:
- "Same compute, different device"
    - Physics can be solved with compute shaders
    - Command dispatch: Device-Generated Commands
- Cascades
    - Shadow cascade
    - Radiance cascade

Design:
- Semantics
    - Geometric semantics
        - BVH
    - Pipeline semantics
        - "Bufferization"
        - Lower to RHI, then to Vulkan/GPU
    - Compute semantics
        - Lowering to SPIR-V

# Timeplan



Conferences:
- I3DG (January)
- High Performance Graphics (April)
- Eurographcis Symposium on Rendering (April)
- CGI (May)
- SIGGRAPH (July)
- EUROGRAPHICS (September)
- ISCA (September)
