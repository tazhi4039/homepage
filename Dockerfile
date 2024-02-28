# Nimのビルドステージ
FROM nimlang/choosenim:latest AS builder
RUN choosenim 2.0.2
WORKDIR /app
COPY ./*.nimble .
RUN mkdir src
RUN touch src/blog.nim
RUN nimble install -y
COPY . .
RUN mkdir /out
RUN nimble c -d:release src/blog.nim -y --out:/out/app

# 実行ステージ
FROM debian:buster-slim
WORKDIR /app
COPY --from=builder /out/app .
RUN apt-get update && apt-get install -y libmariadb-dev
CMD ["./app"]
