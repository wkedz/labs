## GRPC types

Unary - simple request/response,
Server straming - client request server response with stream,
Client streaming - client streams and server simply response,
Bi directonal streaming - bi-directonal streaming.

```proto

service SomeService {
    rpc Unary(HelloRequest) returns (HelloResponse) {};
    rpc ServerStream(HelloRequest) returns (stream HelloResponse) {};
    rpc ClientStream(stream HelloRequest) returns (HelloResponse) {};
    rpc BiDirectionalStream(stream HelloRequest) returns (stream HelloResponse) {};
}
```

## Scalability 

On the server side it is async. On Client it can be async or blocking.

## SSL

* schema based serialization,
* easy ssl certificates initialization,
* interceptors for auth.

## gRPC vs REST

| gRPC | REST |
| ---- | ---- |
|  Protocol Buffers  | Json |
| HTTP2 | HTTP 1 |
| Streaming | Unary |
| Bi directional | Client -> Server |
| Free design | GET/POST/UPDATE/DELETE | 
