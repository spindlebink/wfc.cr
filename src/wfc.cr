require "./lib_wfc"

# WFC Crystal module.
#
# The module implements a character-based texture but no regular image textures
# as of now. You can inherit the abstract `Texture` class to add support for a
# texture format.
#
# See the example for simple usage.
module WFC
  # Abstract class that allows a texture type to interface with WFC.
  #
  # To add WFC generation for a texture type, inherit this class, implementing
  # its methods according to the needs of your texture type. For image textures,
  # this would mean implementing conversion methods to and from a pixel array;
  # for the implemented `CharTexture` type, this means writing codepoints to a
  # buffer, etc.
  abstract class Texture
    # The width of the texture.
    abstract def width

    # The height of the texture.
    abstract def height

    # The number of bytes per cell in the texture. For example, in a char-based
    # texture such as the one provided in the module, this is 1, since each cell
    # is a single byte.
    abstract def bytes_per_cell

    # Converts the texture to a `Bytes`.
    abstract def to_bytes : Bytes

    # Creates a new texture from bytes, width, and height.
    abstract def initialize(bytes, width, height)

    # Calls `WFC.generate` with the passed arguments and `self` as the texture.
    # Does not need to be overridden in subclasses.
    def generate(*arguments)
      WFC.generate(self, *arguments)
    end
  end

  # A texture made up of characters.
  class CharTexture < Texture
    EMPTY_CHAR = UInt8.new ' '.ord

    @chars = [] of Array(UInt8)
    @width = 0
    @height = 0

    getter width
    getter height

    # Initializes an empty texture.
    def initialize
    end

    # Initializes the texture from a set of bytes.
    def initialize(bytes, width, height)
      load_bytes bytes, width, height
    end

    # Initializes the texture from a string.
    def initialize(string)
      string.lines.each_with_index do |line, y|
        line.each_char_with_index do |char, x|
          put x, y, char
        end
      end
    end

    # Creates a new texture from bytes.
    def load_bytes(bytes, width, height)
      if bytes.size < width * height * bytes_per_cell
        raise IndexError.new "Not enough bytes"
      end
      (0...height).each do |y|
        (0...width).each do |x|
          put x, y, bytes[y * width + x]
        end
      end
    end

    # Sets the character at `(x, y)` to `char`.
    def put(x, y, char : UInt8)
      while @chars.size <= y
        @chars << [] of UInt8
      end
      while @chars[y].size < x
        @chars[y] << EMPTY_CHAR
      end
      if !@chars[y][x]?.nil?
        @chars[y][x] = char
      else
        @chars[y] << char
      end
      @width = Math.max(@width, x + 1)
      @height = Math.max(@height, y + 1)
    end

    # Sets the character at `(x, y)` to `char`.
    def put(x, y, char : Char)
      if char.ord > 255
        raise OverflowError.new "Codepoint over 255"
      end
      c = UInt8.new char.ord
      put x, y, c
    end

    # Returns the codepoint at `(x, y)` or nil.
    def get?(x, y)
      @chars[y]?.try &.[x]?
    end

    # Returns the codepoint at `(x, y)` or throws an `IndexError`.
    def get(x, y)
      @chars[y][x]
    end

    # Returns the codepoint at `(x, y)` or nil.
    def char_at?(x, y)
      get?(x, y).try &.chr
    end

    # Returns the codepoint at `(x, y)` as a `Char` or throws an `IndexError`.
    def char_at(x, y)
      get(x, y).chr
    end

    # Converts the texture to an array of bytes.
    def to_bytes : Bytes
      bytes = IO::Memory.new
      @height.times do |y|
        @width.times do |x|
          if x >= @chars[y].size
            bytes.write_byte EMPTY_CHAR
          else
            bytes.write_byte @chars[y][x]
          end
        end
      end
      bytes.to_slice
    end

    # The number of bytes per unit of the texture.
    def bytes_per_cell
      1
    end

    # Prints the texture to an IO.
    def to_s(io : IO)
      empty = EMPTY_CHAR.unsafe_chr
      @height.times do |y|
        size = @chars[y].size
        @width.times do |x|
          if x >= @chars[y].size
            io << empty
          else
            io << @chars[y][x].unsafe_chr
          end
        end
        io << "\n" unless y == @height - 1
      end
    end
  end

  # Generates a new texture from a sample texture.
  def WFC.generate(
    texture : Texture,
    target_width : Int = texture.width * 8,
    target_height : Int = texture.height * 8,
    tile_width : Int = 3,
    tile_height : Int = 3,
    allow_expansion : Bool = true,
    allow_horizontal_flip : Bool = true,
    allow_vertical_flip : Bool = true,
    allow_rotation : Bool = true,
    maximum_iterations : Int = -1,
    retry_until_success : Bool = true
  ) : Texture?
    data = texture.to_bytes

    wfc_image = LibWFC.img_create texture.width, texture.height, texture.bytes_per_cell
    data.copy_to wfc_image.value.data, data.size

    wfc = LibWFC.overlapping \
      target_width,
      target_height,
      wfc_image,
      tile_width,
      tile_height,
      allow_expansion ? 1 : 0,
      allow_horizontal_flip ? 1 : 0,
      allow_vertical_flip ? 1 : 0,
      allow_rotation ? 1 : 0

    if retry_until_success
      result = 0
      while (result = LibWFC.run wfc, maximum_iterations) == 0
        LibWFC.init wfc
      end
    else
      result = LibWFC.run wfc, maximum_iterations
      return nil if result == 0
    end

    output = LibWFC.output_image wfc
    texture_data = output.value.data.to_slice output.value.width * output.value.height * output.value.component_cnt
    output_texture = texture.class.new texture_data, target_width, target_height

    LibWFC.img_destroy wfc_image
    LibWFC.destroy wfc
    output_texture
  end
end
