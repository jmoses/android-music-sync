#!/usr/bin/env ruby

require 'appscript'
require 'fileutils'

app = Appscript.app('iTunes')

playlists = ['Android', 'All Recently Added'] #, 'All Recently Added']

itunes_home = "/Users/jmoses/Music/iTunes/iTunes Media/Music/"

dest = ARGV[0]
dest += '/' unless dest[-1] == '/'

files_in_dest = Dir["#{dest}/**/*"].map {|f| next if File.directory?(f) || File.extname(f) == '.m3u'; f.gsub(%r|#{dest}|, '').gsub(/^\/+/, '') }.compact

files_in_playlists = []

copy_count = 0

playlists.each do |playlist|
  puts playlist

  playlist_fname = "#{playlist}.m3u"
  File.open( File.join(dest, playlist_fname), 'w') do |out|
    app.playlists[playlist].tracks.get.each do |track|
      source = track.location.get.to_s

      filename = File.basename(source)
      relative_source = source.gsub( %r|#{itunes_home}|, '')

      out.puts relative_source

      files_in_playlists << relative_source

      target = File.join(dest, relative_source)

      unless File.exists?( target )
        puts target
        copy_count += 1
        FileUtils.mkdir_p(File.dirname(target)) unless File.exists?(File.dirname(target))
        FileUtils.cp( source, File.join(dest, relative_source) )
      end
    end
  end
end

files_to_delete = files_in_dest - files_in_playlists

puts "Pruning stale files..."
files_to_delete.each do |f|
  puts f
  FileUtils.rm( File.join( dest, f) )
end

puts "#{copy_count} files copied, #{files_to_delete.size} files pruned"

