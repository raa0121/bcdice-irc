# frozen_string_literal: true

require 'forwardable'
require 'yaml'

require 'active_support/core_ext/hash/keys'

require_relative '../irc_bot/config'

module BCDiceIRC
  module GUI
    # プリセットの管理を担当するクラス
    class PresetManager
      include Enumerable
      extend Forwardable

      # 最後に選択されたプリセットのインデックス
      # @return [Integer, nil]
      attr_reader :index_last_selected

      # ロガー
      attr_accessor :logger

      def_delegators(
        :@presets,
        :length,
        :size,
        :empty?
      )

      def_delegator(:@presets, :fetch, :fetch_by_index)

      # 既定のプリセット集を返す
      # @return [PresetManager]
      def self.default
        manager = new
        manager.add(IRCBot::Config::DEFAULT)
        manager
      end

      # 初期化する
      def initialize
        clear
        @logger = nil
      end

      # 各設定に対して処理を行う
      # @yieldparam [IRCBot::Config] config 各設定
      def each(&b)
        @presets.each(&b)
      end

      # プリセットをすべて削除する
      # @return [self]
      def clear
        @index_last_selected = nil
        @presets = []
        @name_index_preset_map = {}

        self
      end

      # 最後に選択されたプリセットの番号を設定する
      # @param [Integer] value プリセット番号
      # @raise [RangeError] +value+ が負か、プリセット数以上だった場合
      def index_last_selected=(value)
        if empty?
          unless value.nil?
            raise TypeError, 'index_last_selected accepts only nil when empty'
          end

          @index_last_selected = nil
          return
        end

        valid_range = 0...length
        unless valid_range.include?(value)
          raise RangeError, "index_last_selected must be in #{valid_range}"
        end

        @index_last_selected = value
      end

      # 設定を追加する
      # @param [IRCBot::Config] config IRCボット設定
      # @return [self]
      def add(*config)
        empty_before_add = empty?

        config.each do |c|
          new_index = @presets.length
          @presets.push(c)
          @name_index_preset_map[c.name] = [new_index, c]
        end

        if empty?
          self.index_last_selected = nil
        elsif empty_before_add
          self.index_last_selected = 0
        end

        self
      end

      # 名前で設定を取り出す
      # @param [String] name 設定名
      # @return [IRCBot::Config]
      def fetch_by_name(name)
        _, config = @name_index_preset_map.fetch(name)
        config
      end

      # ハッシュからプリセット集を作る
      # @param [Hash] hash
      # @return [self]
      def from_hash(hash)
        hash_with_sym_keys = hash.symbolize_keys

        hash_with_sym_keys[:presets]&.each do |h|
          begin
            config = IRCBot::Config.from_hash(h)
            add(config)
          rescue => e
            @logger&.warn('IRCBot::Config.from_hash failed')
            @logger&.exception(e)
          end
        end

        begin
          self.index_last_selected = hash_with_sym_keys[:index_last_selected]
        rescue => e
          @index_last_selected = empty? ? nil : 0
          @logger&.warn("index_last_selected setting failed, set #{@index_last_selected.inspect}")
          @logger&.exception(e)
        end

        self
      end

      # YAMLファイルを読み込んでプリセット集を作る
      # @param [Hash] hash
      # @return [self]
      def load_yaml_file(yaml_path)
        o = YAML.load_file(yaml_path)
        from_hash(o)

        self
      end
    end
  end
end