require 'set'

BOARD_SIDE_SIZE_IN_SQUARES = 8

PAIRS = [
  [[0, 0], [1, 2]],
  [[0, 0], [2, 1]],
  [[0, 0], [3, 3]],
  [[0, 0], [7, 7]],
  [[3, 3], [4, 3]],
  [[7, 7], [0, 0]],
  [[4, 2], [5, 6]],
  [[1, 1], [6, 6]],
  [[2, 3], [5, 4]],
  [[7, 0], [0, 7]],
  [[0, 7], [7, 0]],
  [[2, 2], [3, 5]]
].freeze

PATHS = [
  [[0, 0], [1, 2]],
  [[0, 0], [2, 1]],
  [[0, 0], [1, 2], [3, 3]],
  [[0, 0], [1, 2], [2, 4], [3, 6], [5, 5], [6, 7], [7, 7]],
  [[3, 3], [2, 5], [4, 4], [4, 3]],
  [[7, 7], [6, 5], [5, 3], [4, 1], [2, 0], [1, 2], [0, 0]],
  [[4, 2], [6, 3], [5, 5], [5, 6]],
  [[1, 1], [3, 2], [5, 3], [6, 5], [6, 6]],
  [[2, 3], [4, 4], [5, 4]],
  [[7, 0], [5, 1], [3, 2], [1, 3], [0, 5], [1, 7], [0, 7]],
  [[0, 7], [2, 6], [4, 5], [6, 4], [7, 2], [5, 1], [7, 0]],
  [[2, 2], [3, 4], [3, 5]]
].freeze

NEIGHBOUR_OFFSETS = [
  [-2, 1], [-2, -1], [-1, 2], [-1, -2],
  [1, 2], [1, -2], [2, 1], [2, -1]
].freeze

def valid_square?(coordinates)
  coordinates.all? { |c| c.between?(0, BOARD_SIDE_SIZE_IN_SQUARES - 1) } ? true : false
end

def calculate_neighbours(alpha, beta)
  NEIGHBOUR_OFFSETS.map { |x, y| [x + alpha, y + beta] }
                   .select { |neihgbour| valid_square?(neihgbour) }
end

def create_unvisited_squares(start_square)
  unvisited_squares = Set.new
  BOARD_SIDE_SIZE_IN_SQUARES.times do |i|
    BOARD_SIDE_SIZE_IN_SQUARES.times do |j|
      unvisited_squares.add([i, j]) unless start_square == [i, j]
    end
  end
  unvisited_squares
end

def bfs_over_chessboard(start_square, end_square)
  queue = [start_square]
  unvisited_squares = create_unvisited_squares(start_square)
  referrer_squares = {}
  until queue.empty?
    current_square = queue.shift
    break if current_square == end_square

    calculate_neighbours(*current_square).each do |neighbour|
      next if unvisited_squares.delete?(neighbour).nil?

      queue.append(neighbour)
      referrer_squares[neighbour] = current_square
    end
  end
  referrer_squares
end

def calculate_path(start_square, end_square)
  referrer_squares = bfs_over_chessboard(start_square, end_square)
  result = []
  current_square = end_square
  until current_square == start_square
    result.push(current_square)
    current_square = referrer_squares[current_square]
  end
  result.push(start_square).reverse
end

def knight_moves(start_square, end_square)
  path = calculate_path(start_square, end_square)
  puts "You made it in #{path.length} moves! Here's your path:"
  path.each { |square| print "#{square}\n" }
  path
end

def run_one_testcase(input, expected_output, index, errors)
  given_output = knight_moves(*input)
  return if expected_output.length == given_output.length

  print "\nERROR: GIVEN LENGTH AND EXPECTED LENGTH WERE DIFFERENT AT TESTCASE #{index}\n"
  errors.append([index, given_output])
end

def run_testcases(testcases)
  errors = []
  testcases.each_with_index { |testcase, index| run_one_testcase(*testcase, index, errors) }
  errors
end

def show_error(error, pair_list, path_list)
  print "\nFor pair #{pair_list[error[0]]}\n"
  print "\tExpected output: #{path_list[error[0]]}\n"
  print "\tGiven output: #{error[1]}\n"
end

def main
  errors = run_testcases(PAIRS.zip(PATHS))
  if errors.empty?
    puts 'ALL TESTCASES PASSED'
  else
    errors.each { |error| show_error(error, PAIRS, PATHS) }
  end
end

main
