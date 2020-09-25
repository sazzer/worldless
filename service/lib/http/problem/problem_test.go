package problem_test

import (
	"net/http"
	"testing"

	"github.com/sazzer/worldless/service/lib/http/problem"
	"github.com/stretchr/testify/assert"
)

func TestProblemResponse(t *testing.T) {
	p := problem.Problem{
		Type:       "tag:worldless,2020:problems/something",
		Title:      "Some problem",
		StatusCode: http.StatusBadRequest,
	}

	res, err := p.APIGatewayProxyResponse()

	assert.NoError(t, err)

	assert.Equal(t, http.StatusBadRequest, res.StatusCode)
	assert.Equal(t, map[string]string{"Content-Type": "text/problem+json; charset=utf-8"}, res.Headers)
	assert.Equal(t, "{\"type\":\"tag:worldless,2020:problems/something\",\"title\":\"Some problem\",\"status\":400}",
		res.Body)
}
