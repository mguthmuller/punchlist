# FIXME: need to fix the fact that we create blank lines on files with no issues
module Punchlist
  # Counts the number of 'TODO' and 'FIXME' comments in your code.
  class Punchlist
    def initialize(args,
                   outputter: STDOUT,
                   globber: Dir,
                   file_opener: File)
      @args = args
      @outputter = outputter
      @globber = globber
      @file_opener = file_opener
    end

    def run
      if @args[0] == '--files'
        @source_files_args= @args[1]
      elsif @args[0]
        @outputter.puts "USAGE: punchlist [--files specific_files_list] \n"
        return 0
      end

      analyze_files

      0
    end

    def source_files_args
      @source_files_args ||=
        '{app,lib,test,spec,feature}/**/*.{rb,swift,scala,js,cpp,c,java,py}'
    end

    def analyze_files
      all_output = []
      source_files.each do |filename|
        all_output.concat(look_for_punchlist_items(filename))
      end
      @outputter.print render(all_output)
    end

    def source_files
      @globber.glob(source_files_args)
    end

    def look_for_punchlist_items(filename)
      lines = []
      line_num = 0
      @file_opener.open(filename, 'r') do |file|
        file.each_line do |line|
          line_num += 1
          lines << [filename, line_num, line] if line =~ /TODO|FIXME/i
        end
      end
      lines
    end

    def render(output)
      lines = output.map do |filename, line_num, line|
        "#{filename}:#{line_num}: #{line}"
      end
      lines.join
    end
  end
end
