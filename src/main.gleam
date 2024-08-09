import gleam/bit_array
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import glisten
import http/request
import http/response

pub fn main() {
  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      case msg {
        glisten.Packet(bits) -> {
          let assert Ok(request_string) = bit_array.to_string(bits)
          let assert Ok(request) = request.parse(request_string)

          let status = case request.uri.path {
            "/" -> response.http200
            _ -> response.http404
          }

          let assert Ok(_) =
            status()
            |> response.empty_body
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
