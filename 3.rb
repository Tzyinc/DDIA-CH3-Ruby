# frozen_string_literal: true

class BST
  attr_accessor :root, :size

  def initialize
    @root = nil
    @size = 0
  end

  def search(key)
    curr = @root
    output = nil
    until curr.nil?
      if key == curr.key
        output = "#{curr.key}:#{curr.value}"
        curr = nil
      elsif key > curr.key
        curr = curr.right
      else
        curr = curr.left
      end
    end
    output
  end

  def insert(key, value, should_balance = true)
    if @root.nil?
      @root = Node.new(key, value)
    else
      curr_node = @root
      previous_node = @root
      # while loop helps finding the position of insertion
      until curr_node.nil?
        previous_node = curr_node
        curr_node = if key < curr_node.key
                      curr_node.left
                    else
                      curr_node.right
                    end
      end
      if key < previous_node.key
        previous_node.left = Node.new(key, value)
      else
        previous_node.right = Node.new(key, value)
      end
    end
    return unless should_balance

    balance

    @size += 1
  end

  def balance(nodes = [], initial = false)
    initial ||= nodes.empty?
    nodes = nodes.empty? ? to_array : nodes

    @root = nil if initial

    median = (nodes.length / 2).floor
    left = [*nodes.slice(0, [median, 0].max)]
    right = [*nodes.slice(median + 1, nodes.length)]

    insert(nodes[median].key, nodes[median].value, false)

    balance(left) if left.length.positive?
    balance(right) if right.length.positive?
  end

  def to_array
    current = root
    stack = Stack.new
    arr = []
    loop do
      if !current.nil?
        stack.push(current)
        current = current.left
      else
        break if stack.empty?

        current = stack.pop
        arr.push(current)
        current = current.right
      end
    end
    arr
  end
end

class Node
  attr_accessor :key, :left, :right, :value

  def initialize(key, value)
    @key = key
    @value = value
    @left = nil
    @right = nil
  end
end

class Stack
  def initialize
    @data = []
  end

  def push(element)
    @data.push(element)
  end

  def pop
    @data.pop
  end

  def empty?
    @data.empty?
  end
end

class SSDB
  @file_name = 'ssdb.txt'
  @delim = ';'
  @c0_limit = 5
  @c0 = ::BST.new
  @c1 = File.read(@file_name).split(@delim).map do |item|
    key, value = item.split(/:/, 2)
    Node.new(key, value)
  end || []

  def self.db_set(key, val)
    if @c0.size > @c0_limit
      @c1 = SSDB.merge(@c0.to_array, @c1)

      File.open(@file_name, 'w+') do |f|
        f << @c1.map { |item| "#{item.key}:#{item.value}" }.join(@delim)
      end
      @c0 = ::BST.new
    end
    @c0.insert(key, val)
  end

  def self.merge(a = [], b = [])
    output = []
    while a.length.positive? || b.length.positive?
      if a.length.zero?
        output.push(b.shift)
      elsif b.length.zero?
        output.push(a.shift)
      elsif a[0].key < b[0].key
        output.push(a.shift)
      else
        output.push(b.shift)
      end
    end
    output
  end

  class << self
    attr_accessor :c0, :c1
  end

  def self.db_get(search_key)
    output = c0.search(search_key)

    if output.nil?
      found = c1.find { |item| item.key == search_key }
      output = "#{found.key}:#{found.value}" unless found.nil?
    end
    output
  end
end

# tree = BST.new
# tree.insert('a', 1)
# tree.insert('c', 2)
# tree.insert('b', 3)

# tree.insert('d', 4)

# tree.insert('A', 5)
# tree.insert('B', 6)
# puts 'output', tree.to_array.map(&:value)
# puts tree.search('C')
