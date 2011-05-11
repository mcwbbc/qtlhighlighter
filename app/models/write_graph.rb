class WriteGraph

  @queue = :graphs

  class << self
    def perform(filename, string)
      WriteGraph.append_file(filename, string)
    end

    def append_file(filename, string)
      file_path = File.join(::Rails.root, "#{filename}.nt")
      File.open(file_path, 'a') {|f| f.write(string) }
    end
  end # of self
end

