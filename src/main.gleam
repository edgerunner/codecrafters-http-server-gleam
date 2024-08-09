import gleam/bit_array
import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import glisten
import http/request

const crlf = "\r\n"

const http = "HTTP/1.1 "

const http200 = "200 OK"

const http404 = "404 Not Found"

pub fn main() {
  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      case msg {
        glisten.Packet(bits) -> {
          let assert Ok(request_string) = bit_array.to_string(bits)
          let assert Ok(request) = request.parse(request_string)

          let status = case request.uri.path {
            "/" -> http200
            _ -> http404
          }

          let assert Ok(_) =
            bytes_builder.from_string(http)
            |> bytes_builder.append_string(status)
            |> bytes_builder.append_string(crlf)
            |> bytes_builder.append_string(crlf)
            |> glisten.send(conn, _)

          Nil
        }
        glisten.User(_) -> Nil
      }
      actor.continue(state)
    })
    |> glisten.serve(4221)

  process.sleep_forever()
}
