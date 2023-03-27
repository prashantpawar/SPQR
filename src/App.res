@module("./logo.svg") external logo: string = "default"
%%raw(`import './App.css'`)

type position = {
  number: int,
  time: string,
}
type state = {
  lastServed: option<position>,
  currentTicket: option<position>,
  yourPosition: option<position>,
}
type action = TakeANumber | ServeNext

let reducer = (state, action) => {
  switch action {
  | TakeANumber => state
  | _ => state
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(
    reducer,
    {
      lastServed: None,
      currentTicket: None,
      yourPosition: None,
    },
  )

  <div className="App">
    <p> {"Hello"->React.string} </p>
    {switch state.currentTicket {
    | None => <p> {"1"->React.string} </p>
    | Some(position) =>
      <div>
        <p> {"Currently being served"->React.string} </p>
        <p> {position.number->React.int} </p>
        <p> {position.time->React.string} </p>
      </div>
    }}
    <div>
      {switch state.yourPosition {
      | None =>
        <>
          <p> {"You are not in the queue"->React.string} </p>
          <button onClick={_ => dispatch(TakeANumber)}> {"Take a Number"->React.string} </button>
        </>
      | Some(position) =>
        <div>
          <p> {"Your position is"->React.string} </p>
          <p> {position.number->React.int} </p>
          <p> {position.time->React.string} </p>
        </div>
      }}
    </div>
  </div>
}
