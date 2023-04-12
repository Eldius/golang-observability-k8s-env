package httpclient

import (
	"context"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"net/http"
)

var defaultClient = &http.Client{
	Transport: otelhttp.NewTransport(http.DefaultTransport),
}

type options struct {
	headers map[string]interface{}
}

type Option func(o *options) *options

func WithHeader(k, v string) Option {
	return func(o *options) *options {
		o.headers[k] = v
		return o
	}
}

func MakeRequest(ctx context.Context, url, method string, opts ...Option) (*http.Response, error) {
	opt := &options{headers: make(map[string]interface{})}
	for _, o := range opts {
		opt = o(opt)
	}
	req, err := http.NewRequestWithContext(ctx, method, url, http.NoBody)
	if err != nil {
		return nil, err
	}

	res, err := defaultClient.Do(req)
	if err != nil {
		return nil, err
	}

	return res, nil
}

func GetRequest(ctx context.Context, url string, opts ...Option) (*http.Response, error) {
	return MakeRequest(ctx, url, http.MethodGet, opts...)
}

func GetHTTPClient() *http.Client {
	return defaultClient
}
