class Cave

  def initialize(file:)
    parseFile(file)
  end

  def parseFile(file)
    @waterLeft = file.gets.chomp.to_i
    # Swallow a line, not needed
    file.gets
    @map = []
    file.each_line do |line|
      @map << line.chomp.split("")
    end
  end

  def simulate

  end

  def get_width
    @map[0].length
  end

  def get_height
    @map.length
  end

  def get_row(row)
    @map[row]
  end

  def get_column(column)
    @map.transpose[column]
  end

  def get_water_depth(column)
    depth = 0
    for c in get_column(column)
      return '~' if c == ' ' and depth > 0
      depth += 1 if c == '~'
    end
    depth
  end

  def output
    depths = []
    for column in 0..(get_width-1) do
      depths << get_water_depth(column)
    end
    depths.join(" ")
  end

end
