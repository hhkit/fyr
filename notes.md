- lead with the concepts, not the tool 
    - SSA, low-level targeted rewrites
    - "application-specific integrated circuit"
- don't directly reference the Figure, eg. The raster pipeline (Figure 1)... 
    - "depicted in" "defined in" etc. remove them, noisy words.
    - add the attention paper

=====

# Attention Paper

- Loop tiling, loop fusion are the atomic operations of any loop optimizer.
    - Due to memory constraints, it is common to extract a loop tile to be lowered to execution on the GPU.

# Render Graph Paper

- Taichi is the state of the art we are trying to beat
- Seed idea:
    - Render Graph -> RHI
- Semantics for temporal locality, reactive programming

=====

# Assessors

Timothy M Jones
- already my academic advisor

Robert Mullins
- Timi's suggestion
- Teaches CompArch

Rafal Mantiuk
- Previously supervised Part II project on "Multiresolution Mesh Rendering Engine - Practicalities and Performance"
- Much work on postprocessing, tone mapping, etc.