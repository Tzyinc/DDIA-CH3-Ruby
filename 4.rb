# frozen_string_literal: true

# // https://www.programiz.com/dsa/b-plus-tree

class BPNode
  attr_accessor :order, :values, :keys, :next_value, :parent, :is_leaf, :debug_id

  def initialize(order, debug_id)
    @order = order
    @debug_id = debug_id
    @values = []
    @keys = []
    @next_value = nil
    @parent = nil
    @is_leaf = false
  end

  def insert_at_leaf(key, value)
    if @keys.length.positive?
      (0...@keys.size).each do |i|
        if key == @keys[i]
          @values[i].push(value) unless @values.include? value
          break
        elsif key < @keys[i]
          @values.insert(i, [value])
          @keys.insert(i, key)
          break
        elsif (i + 1) == @keys.length
          @values.push([value])
          @keys.push(key)
        end
      end
    else
      @keys.push(key)
      @values.push([value])
    end
  end
end

class BPlusTree
  attr_accessor :order, :root

  def initialize(order)
    @size = 0
    @order = order
    @root = BPNode.new(order, @size)
    @size += 1
    @root.is_leaf = true
  end

  def insert(key, value)
    old_node = search(key)
    old_node.insert_at_leaf(key, value)
    return debug unless old_node.keys.length == old_node.order

    node = BPNode.new(old_node.order, @size)
    @size += 1
    node.is_leaf = true
    node.parent = old_node.parent
    mid = (old_node.order / 2).ceil - 1
    node.keys = old_node.keys.slice(mid + 1, old_node.keys.size)
    node.values = old_node.values.slice(mid + 1, old_node.values.size)
    node.next_value = old_node.next_value
    old_node.keys = old_node.keys.slice(0, mid + 1)
    old_node.values = old_node.values.slice(0, mid + 1)
    old_node.next_value = node
    insert_in_parent(old_node, node.keys[0], node)
    debug
  end

  def search(key)
    current_node = @root
    while current_node.is_leaf == false
      temp = current_node.keys
      (0...temp.size).each do |i|
        if key == temp[i]
          current_node = current_node.values[i + 1]
          break
        elsif key < temp[i]
          current_node = current_node.values[i]
        elsif (i + 1) == current_node.keys.size
          current_node = current_node.values[i + 1]
        end
      end
    end
    current_node
  end

  def insert_in_parent(n, key, n_dash)
    if @root == n
      root_node = BPNode.new(n.order, @size)
      @size += 1
      root_node.keys = [key]
      root_node.values = [n, n_dash]
      @root = root_node
      n.parent = root_node
      n_dash.parent = root_node
      return
    end
    parent_node = n.parent
    temp = parent_node.values
    (0...temp.size).each do |i|
      next unless temp[i] == n

      parent_node.keys.insert(i, key)
      parent_node.values.insert(i + 1, n_dash)
      next unless parent_node.values.size > parent_node.order

      parent_dash = BPNode.new(parent_node.order, @size)
      @size += 1
      parent_dash.parent = parent_node.parent
      mid = (parent_node.order / 2).ceil - 1
      parent_dash.keys = parent_node.keys.slice(mid + 1, parent_node.keys.size)
      parent_dash.values = parent_node.values.slice(mid + 1, parent_node.values.size)
      key1 = parent_node.keys[mid]
      parent_node.keys = if mid.zero?
                           parent_node.keys.slice(0, mid + 1)
                         else
                           parent_node.keys.slice(0, mid)
                         end
      parent_node.values = parent_node.values.slice(0, mid + 1)

      p_node_val = parent_node.values
      p_node_val.each do |j|
        j.parent = parent_node
      end
      p_dash_val = parent_dash.values
      p_dash_val.each do |k|
        k.parent = parent_dash
      end
      insert_in_parent(parent_node, key1, parent_dash)
    end
  end

  def find(key)
    leaf = search(key)
    arr = leaf.keys
    (0...arr.size).each do |i|
      return { keys: leaf.keys[i], values: leaf.values[i] } if arr[i] == key
    end
  end

  def debug
    to_print = [@root]
    index = 0
    printed = []
    print_list = []

    while to_print.size.positive?
      curr = to_print.shift
      print_list.push(curr)
      printed.push(curr.debug_id)
      if curr.is_leaf == false
        children = curr.values
        children.each do |child|
          to_print.push(child)
        end
      end
      index += 1
    end

    print_list.map do |item|
      {
        file: item.debug_id,
        keys: item.keys,
        values: item.values.map do |value|
          !value.is_a?(Array) ? "file:#{value.debug_id}" : value
        end
      }
    end
  end
end

# btree = BPlusTree.new(3)
# btree.insert('test', 1)
# pp btree.insert('test3', 3)
# pp btree.insert('test2', 2)
# btree.insert('test5', 5)
# btree.insert('test6', 6)
# btree.insert('test4', 4)
# pp btree.insert('test3', 7)

# pp btree.find('test3'), btree.find('test6')
