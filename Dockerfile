FROM rust:1-slim-bullseye AS builder_rvpk
WORKDIR /build
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        git
RUN git clone https://github.com/panzi/rust-vpk.git && cd rust-vpk && git checkout v1.1.0 \
        && CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --release --no-default-features

FROM debian:bullseye-slim
COPY iwatch.patch /tmp
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        iwatch \
        unar \
        patch \
        ; \
    patch $(which iwatch) < /tmp/iwatch.patch; \
    apt-get remove -y --auto-remove \
        patch \
        ; \
    rm /tmp/iwatch.patch; \
    rm -rf /var/lib/apt/lists/*;
COPY app /app
COPY --from=builder_rvpk /build/rust-vpk/target/release/rvpk /app
ENTRYPOINT ["/app/start.sh"]
