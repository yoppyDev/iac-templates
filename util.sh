#!/bin/sh

set -u
. "$(cd "$(dirname "$0")/" && pwd)/.env"

echo "CloudFormation テンプレートを選択してください:"

template=$(find ./cloudformation/stacks -name '*.yaml' | peco)
if [ -z "$template" ]; then
    echo "テンプレートが選択されませんでした。"
    exit 1
fi

stack_name=$(basename "$template" .yaml)
output_template="./cloudformation/output/${stack_name}.yml"

echo "選択されたテンプレート: $stack_name"

createStack() {
    aws cloudformation package \
        --template-file $template \
        --s3-bucket ${BUCKET_NAME} \
        --output-template-file $output_template \
        --profile ${AWS_PROFILE} \
        --region ${REGION}

    rain deploy $output_template $stack_name --profile ${AWS_PROFILE}
}

if ! createStack; then
    echo "スタックの作成に失敗しました。"
    exit 1
fi

echo "スタックが作成されました: $stack_name"
