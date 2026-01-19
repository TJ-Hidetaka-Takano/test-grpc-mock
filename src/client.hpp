#ifndef CLIENT_HPP
#define CLIENT_HPP

#include <memory>

#include <grpcpp/grpcpp.h>

#include "hello.grpc.pb.h"
#include "hello.pb.h"

class HelloClient {
 public:
  HelloClient(std::shared_ptr<grpc::Channel> channel);
  std::string SayHello(const std::string& user);
  void ResetStub(hello::HelloService::StubInterface* stubi);
  void ResetStub();

 private:
  std::shared_ptr<grpc::Channel> channel_;
  std::unique_ptr<hello::HelloService::Stub> stub_;
  hello::HelloService::StubInterface* stubi_;
};

#endif  // CLIENT_HPP
