#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os

# Set the PYTHONPATH to include the directory of this script
sys.path.append(os.path.join(os.path.dirname(__file__), 'proto'))

from concurrent import futures
import grpc
import hello_pb2
import hello_pb2_grpc

class HelloServiceServicer(hello_pb2_grpc.HelloServiceServicer):
    def SayHello(self, request, context):
        print("request.name: ", request.name)
        response = hello_pb2.HelloResponse()
        response.message = 'Hello, {}!'.format(request.name)
        print("response.message: ", response.message)
        return response

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    hello_pb2_grpc.add_HelloServiceServicer_to_server(HelloServiceServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
