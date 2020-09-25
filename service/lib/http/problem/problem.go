package problem

import (
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
)

type Problem struct {
	Type       string `json:"type"`
	Title      string `json:"title"`
	StatusCode int    `json:"status"`
	Detail     string `json:"detail,omitempty"`
	Instance   string `json:"instance,omitempty"`
}

func (p Problem) APIGatewayProxyResponse() (*events.APIGatewayProxyResponse, error) {
	response, err := json.Marshal(p)
	if err != nil {
		return nil, err
	}

	res := events.APIGatewayProxyResponse{
		StatusCode: p.StatusCode,
		Headers:    map[string]string{"Content-Type": "text/problem+json; charset=utf-8"},
		Body:       string(response),
	}

	return &res, nil
}
