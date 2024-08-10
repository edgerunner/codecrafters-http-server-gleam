import argv
import file_streams/file_stream
import gleam/bytes_builder.{type BytesBuilder}
import gleam/dict
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import gleam/result
import glisten
import http/request.{type Request, Get, Post, Request}
import http/response

pub fn main() {
  let argv = argv.load()
  let directory = case argv.arguments {
    ["--directory", d] -> d
    _ -> "./"
  }
  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      case msg {
        glisten.Packet(bits) -> {
          let assert Ok(request) = request.from_bits(bits)
          let assert Ok(_) =
            router(request, directory)
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

pub fn router(request: Request, directory: String) -> BytesBuilder {
  case request.method, request.uri.path {
    Get, "/" -> response.http200() |> response.empty_body
    Get, "/echo/" <> echo_string ->
      response.http200()
      |> case dict.get(request.headers, "Accept-Encoding") {
        Ok("gzip") -> response.gzipped_string_body(_, echo_string, "text/plain")
        _ -> response.string_body(_, echo_string, "text/plain")
      }
    Get, "/user-agent" -> {
      let user_agent_string =
        dict.get(request.headers, "User-Agent")
        |> result.unwrap("")
      response.http200()
      |> response.string_body(user_agent_string, "text/plain")
    }
    Get, "/files/" <> filename -> {
      case file_stream.open_read(directory <> filename) {
        Ok(fs) -> {
          let assert Ok(end) =
            file_stream.position(fs, file_stream.EndOfFile(0))
          let assert Ok(0) =
            file_stream.position(fs, file_stream.BeginningOfFile(0))
          let assert Ok(data) = file_stream.read_bytes(fs, end)
          let assert Ok(_) = file_stream.close(fs)

          response.http200()
          |> response.bytes_body(data, "application/octet-stream")
        }
        Error(_) -> response.http404() |> response.empty_body
      }
    }

    Post, "/files/" <> filename -> {
      let assert Ok(fs) = file_stream.open_write(directory <> filename)
      let assert Ok(_) = file_stream.write_chars(fs, request.body)
      let assert Ok(_) = file_stream.close(fs)
      response.http201() |> response.empty_body
    }

    _, _ -> response.http404() |> response.empty_body
  }
}
