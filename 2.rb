# frozen_string_literal: true

require 'json'

class IndexedDb
  @file_name = 'indexedDb.txt'
  @index_name = 'index.json'
  @delim = ';'
  @hash = JSON.parse(File.read(@index_name)) || {}

  def self.db_set(key, val)
    index = File.size(@file_name)
    @hash[key.to_sym] = index
    File.write(@file_name, "#{key}:#{val}#{@delim}", mode: 'a')
    IndexedDb.save_hash
  end

  def self.db_get(key)
    output = nil

    case key
    when String
      output = IndexedDb.db_get_from_index(@hash[key])
    when Symbol
      output = IndexedDb.db_get_from_index(@hash[key.to_s])
    end
    output
  end

  def self.db_get_from_index(search_index)
    output = nil
    File.open(@file_name) do |f|
      f.seek(search_index, :SET)
      content, * = f.read.split(@delim)
      output = content
    end
    output
  end

  def self.save_hash
    File.open(@index_name, 'w+') do |f|
      f << @hash.to_json
    end
  end
end

puts IndexedDb.db_get('test3')
puts IndexedDb.db_get(:test3)
