class Cave

  attr_reader :waterLeft

  def initialize(file:)
    parseFile(file)
  end

  def parseFile(file)
    @waterLeft = file.gets.chomp.to_i
    @waterLeft -= 1 # Start with one unit there
    # Swallow a line, not needed
    file.gets
    @map = []
    file.each_line do |line|
      @map << line.chomp.split("")
    end
  end

  def getWaterPosition
    return @waterPosition if @waterPosition
    # We haven't started simulating yet, should just be one water source
    # TODO make it harder and have multiple sources ;)
    for row in 0..(getHeight-1) do
      column = getRow(row).index('~')
      if column
        @waterPosition = {row: row, column: column}
        break
      end
    end
    @waterPosition
  end

  def flowUp(row)
    return if row == 0
    row -= 1
    column = getRow(row).rindex('~')
    return unless column
    if column + 1 < getWidth && @map[row][column + 1] == ' '
      # There is an empty place, call this the new waterPosition
      @waterPosition = {row: row, column: column}
    else
      return flowUp(row)
    end
    @waterPosition
  end

  def to_s
    str = ""
    str << waterLeft.to_s
    str << "\n\n"
    waterPosition = getWaterPosition
    for row in 0..(getHeight-1)
      line = getRow(row)
      if row == waterPosition[:row]
        line = line.dup
        line[waterPosition[:column]] = '@'
      end
      str << line.join
      str << "\n"
    end
    str
  end

  def simulate
    while waterLeft > 0 do
      puts self
      waterPosition = getWaterPosition
      # Check whether water can flow down, then across to left, otherwise we are going up
      row = waterPosition[:row]
      column = waterPosition[:column]
      if row + 1 < getHeight && @map[row + 1][column] == ' '
        puts "Moving down"
        # Square below us is empty
        row += 1
      elsif column + 1 < getWidth && @map[row][column + 1] == ' '
        puts "Moving left"
        # Square to left of us is empty
        column += 1 
      else
        puts "Trying to flow up"
        # Try flow up, otherwise fall through
        if flowUp(row)
          next
        end
      end

      if waterPosition[:row] == row && waterPosition[:column] == column
        # No change, stop simulation
        break
      else
        @waterPosition = {row: row, column: column}
        @map[row][column] = '~' 
        @waterLeft -= 1
      end
    end
  end

  def getWidth
    @map[0].length
  end

  def getHeight
    @map.length
  end

  def getRow(row)
    @map[row]
  end

  def getColumn(column)
    @map.transpose[column]
  end

  def getWaterDepth(column)
    depth = 0
    for c in getColumn(column)
      return '~' if c == ' ' and depth > 0
      depth += 1 if c == '~'
    end
    depth
  end

  def output
    depths = []
    for column in 0..(getWidth-1) do
      depths << getWaterDepth(column)
    end
    depths.join(" ")
  end

end
