import gleam/io

import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import glisten

const crlf = "\r\n"

const http = "HTTP/1.1 "

const http200 = "200 OK"

pub fn main() {
  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(_msg, state, conn) {
      let assert Ok(_) =
        bytes_builder.from_string(http)
        |> bytes_builder.append_string(http200)
        |> bytes_builder.append_string(crlf)
        |> bytes_builder.append_string(crlf)
        |> glisten.send(conn, _)
      actor.continue(state)
    })
    |> glisten.serve(4221)

  process.sleep_forever()
}
