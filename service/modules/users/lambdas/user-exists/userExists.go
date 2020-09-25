package main

import (
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cognitoidentityprovider"
	"github.com/sazzer/worldless/service/lib/http/problem"
)

func handleRequest(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	mySession := session.Must(session.NewSession())
	svc := cognitoidentityprovider.New(mySession)

	userPool := os.Getenv("AWS_COGNITO_USERPOOL")
	username := req.PathParameters["username"]

	user, err := svc.AdminGetUser(&cognitoidentityprovider.AdminGetUserInput{
		UserPoolId: &userPool,
		Username:   &username,
	})

	var res *events.APIGatewayProxyResponse

	if err != nil {
		res, err = problem.Problem{
			Type:       "tag:worldless,2020:problems/unknown_user",
			Title:      "The user was not found",
			StatusCode: http.StatusNotFound,
		}.APIGatewayProxyResponse()
	} else {
		res = &events.APIGatewayProxyResponse{
			StatusCode: http.StatusOK,
			Headers:    map[string]string{"Content-Type": "text/plain; charset=utf-8"},
			Body:       user.String(),
		}
	}

	if err != nil {
		return nil, err
	}
	return res, nil
}

func main() {
	lambda.Start(handleRequest)
}
