@[Link(ldflags: "#{__DIR__}/wfc.o")]
lib LibWFC
  enum Direction
    Up
    Down
    Left
    Right
  end

  enum Method
    Overlapping
    Tiled
  end

  struct Tile
    image : Image*
    freq : LibC::Int
  end

  struct Cell
    tiles : LibC::Int*
    tile_cnt : LibC::Int
    sum_freqs : LibC::Int
    entropy : LibC::Float
  end

  struct Prop
    src_cell_idx : LibC::Int
    dst_cell_idx : LibC::Int
    direction : Direction
  end

  struct Image
    data : LibC::Char*
    component_cnt : LibC::Int
    width : LibC::Int
    height : LibC::Int
  end

  struct WFC
    method : Method
    seed : LibC::UInt

    image : Image*
    tile_width : LibC::Int
    tile_height : LibC::Int
    expand_input : LibC::Int
    xflip_tiles : LibC::Int
    yflip_tiles : LibC::Int
    rotate_tiles : LibC::Int
    tiles : Tile*
    tile_cnt : LibC::Int
    sum_freqs : LibC::Int

    output_width : LibC::Int
    output_height : LibC::Int
    cells : Cell*
    cell_cnt : LibC::Int

    props : Prop*
    prop_cnt : LibC::Int
    prop_idx : LibC::Int
    collapsed_cell_cnt : LibC::Int

    allowed_tiles : StaticArray(LibC::Int, 4)*
  end

  # -------------------------------------------------------------------------- #

  fun overlapping = wfc_overlapping(
    width : LibC::Int,
    height : LibC::Int,
    image : Image*,
    tile_width : LibC::Int,
    tile_height : LibC::Int,
    expand : LibC::Int,
    horizontal_flip : LibC::Int,
    vertical_flip : LibC::Int,
    rotate : LibC::Int
  ) : WFC*
  fun init = wfc_init(wfc : WFC*)
  fun run = wfc_run(wfc : WFC*, max_collapse_cnt : LibC::Int) : LibC::Int
  fun output_image = wfc_output_image(wfc : WFC*) : Image*
  fun destroy = wfc_destroy(wfc : WFC*)
  fun export = wfc_export(wfc : WFC*, filename : LibC::Char*)
  fun img_load = wfc_img_load(filename : LibC::Char*) : Image*
  fun img_create = wfc_img_create(width : LibC::Int, height : LibC::Int, component_count : LibC::Int) : Image*
  fun img_destroy = wfc_img_destroy(image : Image*)
end
