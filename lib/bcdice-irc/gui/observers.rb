# frozen_string_literal: true

module BCDiceIRC
  module GUI
    # オブザーバを格納するモジュール
    module Observers; end
  end
end

require_relative 'observers/state'
require_relative 'observers/preset_load'
require_relative 'observers/preset_save'
require_relative 'observers/preset_delete'
require_relative 'observers/preset_save_action'
require_relative 'observers/preset_deletability'
require_relative 'observers/password_usage'
require_relative 'observers/game_system'
