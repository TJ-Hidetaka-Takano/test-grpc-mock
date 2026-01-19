#include "client.hpp"

#include <iostream>
#include <memory>
#include <string>

HelloClient::HelloClient(std::shared_ptr<grpc::Channel> channel)
    : channel_(channel),
      stub_(hello::HelloService::NewStub(channel)),
      stubi_(stub_.get()) {}

std::string HelloClient::SayHello(const std::string& user) {
  hello::HelloRequest request;
  request.set_name(user);

  hello::HelloResponse response;

  grpc::ClientContext context;

  grpc::Status status = stubi_->SayHello(&context, request, &response);

  if (status.ok()) {
    return response.message();
  } else {
    std::cout << "RPC failed" << std::endl;
    return "RPC failed";
  }
}

void HelloClient::ResetStub(hello::HelloService::StubInterface* stubi) {
  stubi_ = stubi;
}

void HelloClient::ResetStub() {
  stub_ = hello::HelloService::NewStub(channel_);
  stubi_ = stub_.get();
}
