# frozen_string_literal: true

require_relative 'base'

module BCDiceIRC
  module GUI
    module State
      # 接続中状態
      class Connecting < Base
        # 状態を初期化する
        # @param [GUI::Application] app GUIアプリケーション
        def initialize(app)
          super('connecting', app)

          @main_window_title = '接続中...'

          @connect_disconnect_button_label = CONNECT_BUTTON_LABEL
          @connect_disconnect_button_sensitive = false
        end

        # 接続状況を返す
        # @return [String]
        def connection_status
          "#{@app.irc_bot_config.end_point} に接続中..."
        end

        # 状態に入ったときの処理
        # @return [void]
        def on_enter
          @app.last_connection_error = nil
        end

        # 接続/切断ボタンがクリックされたときの処理
        # @return [void]
        # @todo 接続を中断できるようにする
        def connect_disconnect_button_on_clicked
          # 何もしない
        end
      end
    end
  end
end
