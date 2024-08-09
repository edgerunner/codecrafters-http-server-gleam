import gleam/bytes_builder.{type BytesBuilder}
import gleam/erlang/process
import gleam/list
import gleam/option.{None}
import gleam/otp/actor
import gleam/result
import glisten
import http/request.{type Request, Request}
import http/response

pub fn main() {
  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      case msg {
        glisten.Packet(bits) -> {
          let assert Ok(request) = request.from_bits(bits)
          let assert Ok(_) =
            router(request)
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

pub fn router(request: Request) -> BytesBuilder {
  case request.uri.path {
    "/" -> response.http200() |> response.empty_body
    "/echo/" <> echo_string ->
      response.http200()
      |> response.string_body(echo_string, "text/plain")
    "/user-agent" -> {
      let user_agent_string =
        list.find_map(request.headers, fn(header) {
          case header.name {
            "User-Agent" -> Ok(header.value)
            _ -> Error(Nil)
          }
        })
        |> result.unwrap("")
      response.http200()
      |> response.string_body(user_agent_string, "text/plain")
    }

    _ -> response.http404() |> response.empty_body
  }
}
