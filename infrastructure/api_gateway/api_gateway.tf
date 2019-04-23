resource "aws_api_gateway_rest_api" "public_api" {
  name        = "${terraform.workspace}-${var.app_name}-api"
  description = "Security Analytics public API, which will be used by front end apps"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "public_api_authorizer" {
  name            = "${terraform.workspace}-${var.app_name}-auth"
  rest_api_id     = "${aws_api_gateway_rest_api.public_api.id}"
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = ["${var.user_pool_arn}"]
}

resource "aws_api_gateway_rest_api" "private_api" {
  name        = "${terraform.workspace}-${var.app_name}-private-api"
  description = "Security Analytics private API, which internal services can use"

  endpoint_configuration {
    # N.B. To actually use this api we will need to setup VPC endpoints for api gateway
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-apis.html
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_deployment" "stage" {
  depends_on = [
    "aws_api_gateway_integration_response.to_delete",
    "aws_api_gateway_integration.to_delete"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.public_api.id}"
  stage_name  = "${terraform.workspace}"
}
