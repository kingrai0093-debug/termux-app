FROM alpine:3.20

RUN apk add --no-cache ttyd bash

EXPOSE 8080
CMD ["ttyd", "--writable", "--port", "8080", "bash"]
