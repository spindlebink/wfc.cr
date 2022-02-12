require "../src/wfc"

string = <<-TEXTURE
.................
..####..####.....
.###########.....
.#####..####.....
..###...####.....
.........##......
...##########....
...###########...
...###########...
.................
TEXTURE

texture = WFC::CharTexture.new string
new_texture = texture.generate 134, 64

puts new_texture
