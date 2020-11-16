FROM nats:2-alpine

COPY run-nats-server.sh .

CMD [ "/run-nats-server.sh" ]
