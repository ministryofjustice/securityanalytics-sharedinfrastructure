resource "aws_api_gateway_method" "to_delete" {
  rest_api_id   = "${aws_api_gateway_rest_api.public_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.public_api.root_resource_id}"
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.public_api_authorizer.id}"
}

resource "aws_api_gateway_integration" "to_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.public_api.id}"
  resource_id = "${aws_api_gateway_rest_api.public_api.root_resource_id}"
  http_method = "${aws_api_gateway_method.to_delete.http_method}"
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\":200}"
  }
}

resource "aws_api_gateway_method_response" "to_delete_200" {
  rest_api_id = "${aws_api_gateway_rest_api.public_api.id}"
  resource_id = "${aws_api_gateway_rest_api.public_api.root_resource_id}"
  http_method = "${aws_api_gateway_method.to_delete.http_method}"
  status_code = "200"

  response_models {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "to_delete" {
  rest_api_id = "${aws_api_gateway_rest_api.public_api.id}"
  resource_id = "${aws_api_gateway_rest_api.public_api.root_resource_id}"
  http_method = "${aws_api_gateway_method.to_delete.http_method}"
  status_code = "${aws_api_gateway_method_response.to_delete_200.status_code}"

  response_templates {
    "application/json" = ""
  }
}
