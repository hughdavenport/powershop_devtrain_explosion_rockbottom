class Cave

  attr_reader :waterLeft
  attr_accessor :debug

  def initialize(debug: false, file:)
    self.debug = debug
    @direction = 1
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
    # Or, we are sending in partial input, which allows us to test stream
    # TODO make it harder and have multiple sources ;)
    for row in (getHeight-1).downto(0) do
      column = getRow(row).rindex('~')
      if column
        @waterPosition = {row: row, column: column}
        break
      end
    end
    @waterPosition
  end

  def flowUp(row=getWaterPosition[:row], column = getWaterPosition[:column])
    return if row == 0
    # Find a connected stream from our position
    for i in 0..(getWidth-1) do
      if column + i < getWidth && @map[row][(column..(column + i))] == ['~'] * (i + 1) && @map[row - 1][column + i] == '~'
        # Connected, and go up
        # In a multisource world, we get all of these potentials, then add to list of sources
        @waterPosition = {row: row - 1, column: column + i}
        return @waterPosition
      elsif column - i < getWidth && @map[row][((column - i)..column)] == ['~'] * (i + 1) && @map[row - 1][column - i] == '~'
        # Connected, and go up
        # In a multisource world, we get all of these potentials, then add to list of sources
        @waterPosition = {row: row - 1, column: column - i}
        return @waterPosition
      end
    end
    nil
  end

  def to_s
    str = ""
    str << (waterLeft+1).to_s
    str << "\n\n"
    waterPosition = getWaterPosition
    for row in 0..(getHeight-1)
      line = getRow(row)
      if debug && row == waterPosition[:row]
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
      puts self if debug
      waterPosition = getWaterPosition
      # Check whether water can flow down, then across to left, otherwise we are going up
      row = waterPosition[:row]
      column = waterPosition[:column]
      # OPTIONAL: move right if possible, this allows us to have underhangs, and sources not on left edge
      skipadd = 0
      skipadd += 1 while column + skipadd * @direction >= 0 && column + skipadd * @direction < getWidth && @map[row][column + skipadd * @direction] == '~'
      skipminus = 0
      skipminus += 1 while column - skipminus * @direction >= 0 && column - skipminus * @direction < getWidth && @map[row][column - skipminus * @direction] == '~'
      if row + 1 < getHeight && @map[row + 1][column] == ' '
        puts "Moving down" if debug
        # Square below us is empty
        row += 1
      elsif column + skipadd * @direction >= 0 && column + skipadd * @direction < getWidth && @map[row][column + skipadd * @direction] == ' '
        puts "Moving " + (@direction > 0 ? "left" : "right") if debug
        # Some square to the side of us is empty, between us and that is just water
        column += skipadd * @direction
        @direction *= -1
      elsif column - skipminus * @direction >= 0 && column - skipminus * @direction < getWidth && @map[row][column - skipminus * @direction] == ' '
        puts "Moving " + (@direction > 0 ? "right" : "left") if debug
        # Some square to the side of us is empty, between us and that is just water
        column -= skipminus * @direction
        @direction *= -1
      else
        puts "Trying to flow up" if debug
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
