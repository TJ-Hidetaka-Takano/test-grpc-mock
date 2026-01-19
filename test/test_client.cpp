#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "client.hpp"
#include "hello_mock.grpc.pb.h"

using ::testing::_;
using ::testing::AtLeast;
using ::testing::DoAll;
using ::testing::Return;
using ::testing::SaveArg;
using ::testing::SetArgPointee;
using ::testing::WithArg;

// Test fixture for HelloClient
class HelloClientTest : public ::testing::Test {
 protected:
  void SetUp() override {
    client = std::make_unique<HelloClient>(grpc::CreateChannel(
        "localhost:50051", grpc::InsecureChannelCredentials()));
    mock_stub = new hello::MockHelloServiceStub();
    client->ResetStub(mock_stub);
  }

  void TearDown() override { delete mock_stub; }

  std::unique_ptr<HelloClient> client;
  hello::MockHelloServiceStub* mock_stub;
};

TEST_F(HelloClientTest, SayHelloSuccess) {
  // SayHelloのモック準備
  hello::HelloRequest request;
  hello::HelloResponse response;
  response.set_message("Hello, test!");
  EXPECT_CALL(*mock_stub, SayHello(_, _, _))
      .Times(AtLeast(1))
      .WillOnce(DoAll(SetArgPointee<2>(response), Return(grpc::Status::OK)));

  std::string reply = client->SayHello("test");
  EXPECT_EQ(reply, "Hello, test!");
}

TEST_F(HelloClientTest, SayHelloFailure) {
  // SayHelloのモック準備
  hello::HelloRequest request;
  hello::HelloResponse response;
  EXPECT_CALL(*mock_stub, SayHello(_, _, _))
      .WillOnce(::testing::Return(
          grpc::Status(grpc::StatusCode::UNAVAILABLE, "Unavailable")));

  std::string reply = client->SayHello("test");
  EXPECT_EQ(reply, "RPC failed");
}
