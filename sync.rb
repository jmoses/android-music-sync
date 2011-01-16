#!/usr/bin/env ruby

require 'appscript'
require 'fileutils'

app = Appscript.app('iTunes')

playlists = ['Android'] #, 'All Recently Added']

itunes_home = "/Users/jmoses/Music/iTunes/iTunes Media/Music/"

dest = "/tmp/testing/"

files_in_dest = Dir["#{dest}/**/*"].map {|f| next if File.directory?(f); f.gsub(%r|#{dest}|, '').gsub(/^\/+/, '') }.compact

files_in_playlists = []

playlists.each do |playlist|
  puts playlist
  app.playlists[playlist].tracks.get.each do |track|
    source = track.location.get.to_s

    filename = File.basename(source)
    relative_source = source.gsub( %r|#{itunes_home}|, '')

    files_in_playlists << relative_source

    target = File.join(dest, relative_source)

    unless File.exists?( target )
      puts "Copying #{relative_source}"

      FileUtils.mkdir_p(File.dirname(target)) unless File.exists?(File.dirname(target))
      FileUtils.cp( source, File.join(dest, relative_source) )
    end
  end
end

files_to_delete = files_in_dest - files_in_playlists

puts "Found #{files_to_delete.size} to delete"

