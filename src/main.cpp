#include <iostream>

#include "client.hpp"

int main(int argc, char** argv) {
  HelloClient client(grpc::CreateChannel("localhost:50051",
                                         grpc::InsecureChannelCredentials()));
  std::string user("world");
  std::string reply = client.SayHello(user);
  std::cout << "Received: " << reply << std::endl;

  return 0;
}
