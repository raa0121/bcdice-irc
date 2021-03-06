#!/usr/bin/env ruby
# frozen_string_literal: true

bcdice_dir = File.expand_path(
  File.join('..', 'vendor', 'bcdice', 'src'),
  __dir__
)
lib_dir = File.expand_path(
  File.join('..', 'lib'),
  __dir__
)
dirs = [bcdice_dir, lib_dir]
dirs.each do |dir|
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

require 'bundler/setup'
require 'optparse'

require 'bcdice-irc'
require 'bcdice-irc/gui/application'

begin
  # デバッグ用にbyebugを読み込む
  require 'byebug'
rescue LoadError
  # デバッグ用ライブラリがインストールされていなかったら何もしない
end

presets_yaml_path = File.expand_path('../config/presets.yaml', __dir__)
log_level = :warn

OptionParser.new do |opt|
  opt.on('-v', '--verbose', 'ログを冗長に出力します') do
    log_level = :info
  end

  opt.on('--debug', 'デバッグログを出力します') do
    log_level = :debug
  end

  opt.version = BCDiceIRC::VERSION
  opt.release = BCDiceIRC::COMMIT_ID

  opt.parse!(ARGV)
end

BCDiceIRC::GUI::Application.new(presets_yaml_path, log_level).start!
