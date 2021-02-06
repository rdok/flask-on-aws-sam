start:
	sam local start-api

unit: .pytest_cache
	rm -rf .aws-sam/
	python -m pytest tests/unit -v

integration: .pytest_cache .aws-sam
	export AWS_REGION=us-east-1 \
	export AWS_SAM_STACK_NAME=flask-api-aws-sam-integration \
		&& sam deploy --stack-name $${AWS_SAM_STACK_NAME} \
		   --region $${AWS_REGION} \
		   --s3-bucket rdok-testing-deployments-us-east-1 \
		   --s3-prefix rdok-testing-flask-api-aws-sam \
		   --no-confirm-changeset \
		   --capabilities CAPABILITY_IAM \
		&& python -m pytest tests/integration -v \

integration-destroy:
	export AWS_REGION=us-east-1 \
	export AWS_SAM_STACK_NAME=flask-api-aws-sam-integration \
    && aws cloudformation --region $${AWS_REGION} \
        delete-stack --stack-name $${AWS_SAM_STACK_NAME}

.pytest_cache:
	pip install -r tests/requirements.txt --user

invoke: .aws-sam
	sam local invoke HelloWorldFunction --event events/event.json

.aws-sam:
	sam build --use-container
