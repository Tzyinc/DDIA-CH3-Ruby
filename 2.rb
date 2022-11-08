# frozen_string_literal: true

require 'json'

class PersistedHash
  attr_reader :file_name, :hash

  def initialize(file_name = 'index.json')
    @file_name = file_name
    @hash = JSON.parse(File.read(file_name)) || {}
  end

  def [](key)
    hash[key]
  end

  def []=(key, byte_offset)
    hash[key] = byte_offset
    save_hash
  end

  private

  def save_hash
    File.open(file_name, 'w+') do |f|
      f << hash.to_json
    end
  end
end

class IndexedDb
  DELIMINATOR = ';'

  def initialize(file_name = 'indexedDb.txt')
    @file_name = file_name
    @index = PersistedHash.new
  end

  def set(key, val)
    byte_offset = File.size(@file_name)
    File.write(@file_name, "#{key}:#{val}#{DELIMINATOR}", mode: 'a')
    @index[key] = byte_offset
  end

  def get(key)
    offset = @index[key.to_s]
    get_value(byte_offset)
  end

  private

  def get_value(byte_offset)
    output = nil
    File.open(@file_name) do |f|
      f.seek(byte_offset, :SET)
      content, * = f.read.split(DELIMINATOR)
      output = content
    end
    output
  end
end

db = IndexedDb.new
puts db.get('test3')
puts db.get(:test3)
