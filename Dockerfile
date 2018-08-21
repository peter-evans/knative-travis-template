FROM golang

ADD . /go/src/github.com/peter-evans/knative-travis-template

RUN go install github.com/peter-evans/knative-travis-template

ENTRYPOINT /go/bin/helloworld