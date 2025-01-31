import logging
from ask_sdk_core.skill_builder import SkillBuilder
from ask_sdk_core.dispatch_components import (
    AbstractRequestHandler, AbstractExceptionHandler)
import ask_sdk_core.utils as ask_utils
from ask_sdk_model import Response


# ログ設定
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# スキルメッセージ定義
WELCOME_MESSAGE = "キントーンへようこそ。ご用件をお知らせください。"
HELP_MESSAGE = "このスキルでは、プレイリストの音楽を再生できます。プレイリストの音楽を流して、と話しかけてください。"
GOODBYE_MESSAGE = "ご利用ありがとうございました。またお話ししましょう。"
ERROR_MESSAGE = "申し訳ありません。エラーが発生しました。もう一度お試しください。"

class LaunchRequestHandler(AbstractRequestHandler):
    """スキル起動時のハンドラ"""

    def can_handle(self, handler_input):
        return ask_utils.is_request_type("LaunchRequest")(handler_input)

    def handle(self, handler_input):
        speak_output = WELCOME_MESSAGE

        return (
            handler_input.response_builder
                .speak(speak_output)
                .ask(speak_output)
                .response
        )

class AskEventIntentHandler(AbstractRequestHandler):
    """askEventIntentのハンドラ"""

    def can_handle(self, handler_input):
        return ask_utils.is_intent_name("askEventIntent")(handler_input)

    def handle(self, handler_input):
        # プレイリスト再生のロジックをここに実装
        # 例として、プレイリストを再生する旨をユーザーに伝えます。

        speak_output = "プレイリストの音楽を再生します。"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .response
        )

class HelpIntentHandler(AbstractRequestHandler):
    """ヘルプインテントのハンドラ"""

    def can_handle(self, handler_input):
        return ask_utils.is_intent_name("AMAZON.HelpIntent")(handler_input)

    def handle(self, handler_input):
        speak_output = HELP_MESSAGE

        return (
            handler_input.response_builder
                .speak(speak_output)
                .ask(speak_output)
                .response
        )

class CancelOrStopIntentHandler(AbstractRequestHandler):
    """キャンセル・ストップインテントのハンドラ"""

    def can_handle(self, handler_input):
        return (
            ask_utils.is_intent_name("AMAZON.CancelIntent")(handler_input) or
            ask_utils.is_intent_name("AMAZON.StopIntent")(handler_input)
        )

    def handle(self, handler_input):
        speak_output = GOODBYE_MESSAGE

        return (
            handler_input.response_builder
                .speak(speak_output)
                .response
        )

class SessionEndedRequestHandler(AbstractRequestHandler):
    """セッション終了時のハンドラ"""

    def can_handle(self, handler_input):
        return ask_utils.is_request_type("SessionEndedRequest")(handler_input)

    def handle(self, handler_input):
        # セッション終了時のクリーンアップ処理があればここに記述します。
        return handler_input.response_builder.response

class IntentReflectorHandler(AbstractRequestHandler):
    """デバッグ用のインテントリフレクタ"""

    def can_handle(self, handler_input):
        return ask_utils.is_request_type("IntentRequest")(handler_input)

    def handle(self, handler_input):
        intent_name = ask_utils.get_intent_name(handler_input)
        speak_output = f"{intent_name}がトリガーされました。"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .response
        )

class CatchAllExceptionHandler(AbstractExceptionHandler):
    """全ての例外をキャッチするハンドラ"""

    def can_handle(self, handler_input, exception):
        return True

    def handle(self, handler_input, exception):
        logger.error(exception, exc_info=True)
        speak_output = ERROR_MESSAGE

        return (
            handler_input.response_builder
                .speak(speak_output)
                .ask("申し訳ありません。もう一度お試しください。")
                .response
        )

# スキルビルダーの初期化
sb = SkillBuilder()

# リクエストハンドラの登録
sb.add_request_handler(LaunchRequestHandler())
sb.add_request_handler(AskEventIntentHandler())
sb.add_request_handler(HelpIntentHandler())
sb.add_request_handler(CancelOrStopIntentHandler())
sb.add_request_handler(SessionEndedRequestHandler())
sb.add_request_handler(IntentReflectorHandler())

# 例外ハンドラの登録
sb.add_exception_handler(CatchAllExceptionHandler())

# Lambdaハンドラのエントリポイント
handler = sb.lambda_handler()
