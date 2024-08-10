import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/result
import gleam/uri.{type Uri}
import party.{type Parser, do, try}

pub type Request {
  Request(method: Method, uri: Uri, headers: Dict(String, String), body: String)
}

pub type Method {
  Get
  Post
}

pub type Error {
  InvalidURI
  NotUTF8
}

pub fn parse(data: String) -> Result(Request, party.ParseError(Error)) {
  party.go(http_request(), data)
}

fn http_request() -> Parser(Request, Error) {
  use method <- do(method())
  use uri <- do(uri())
  use _ <- do(party.string(" HTTP/1.1\r\n"))
  use headers <- do(headers())
  use body <- do(body())
  Request(method: method, uri: uri, headers: headers, body: body)
  |> party.return
}

fn method() -> Parser(Method, Error) {
  party.choice([method_parser("GET", Get), method_parser("POST", Post)])
}

fn method_parser(string: String, method: Method) -> Parser(Method, Error) {
  use _ <- do(party.string(string))
  use _ <- do(party.whitespace1())
  party.return(method)
}

fn uri() -> Parser(Uri, Error) {
  use uri_string <- try(
    party.satisfy(fn(ch) { ch != " " }) |> party.many1_concat(),
  )
  uri.parse(uri_string)
  |> result.replace_error(InvalidURI)
}

fn headers() -> Parser(Dict(String, String), Error) {
  use list <- do(party.many1(header()))
  dict.from_list(list)
  |> party.return
}

fn header() -> Parser(#(String, String), Error) {
  use name <- do(party.satisfy(fn(ch) { ch != ":" }) |> party.many1_concat())
  use _ <- do(party.string(":"))
  use _ <- do(party.whitespace())
  use value <- do(
    party.satisfy(fn(ch) { ch != "\r\n" }) |> party.many1_concat(),
  )
  use _ <- do(party.string("\r\n"))
  #(name, value) |> party.return
}

fn body() -> Parser(String, Error) {
  use _ <- do(party.string("\r\n"))
  use body <- do(party.many_concat(party.satisfy(fn(_) { True })))
  party.return(body)
}

pub fn from_bits(data: BitArray) -> Result(Request, party.ParseError(Error)) {
  bit_array.to_string(data)
  |> result.replace_error(party.UserError(NotUTF8, pos: party.Position(0, 0)))
  |> result.then(parse)
}
