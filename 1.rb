class SimplestDb
    @file_name = 'simplestDb.txt'
    @delim = ";"

    def self.db_set(key, val)
        File.write(@file_name, "#{key}:#{val}#{@delim}", mode: "a")
    end

    def self.db_get(search_key)
        output = nil
        file_data = File.read(@file_name).split(@delim)
        index = file_data.length - 1
        while output == nil && index >=0 do
            key, * = file_data[index].split(/:/, 2)
            if key == search_key
                output = file_data[index]
            end
            index = index -1
        end
        output
    end
end

SimplestDb.db_get('test')
