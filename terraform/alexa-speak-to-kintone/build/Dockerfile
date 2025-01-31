# Lambda関数用Dockerfile
# ARG BASE_IMAGE
# FROM ${BASE_IMAGE}

FROM python:3.8-slim

RUN pip install boto3 ask-sdk-core ask-sdk-model awslambdaric

WORKDIR /var/task

# Lambda関数のコードをコピー
COPY lambda_function.py ./

# エントリーポイントを設定
ENTRYPOINT [ "python3", "-m", "awslambdaric" ]

# ハンドラを指定
CMD ["lambda_function.handler"]