@module("./logo.svg") external logo: string = "default"
%%raw(`import './index.css'`)

open Types
type state = {
  queue: option<GunDb.Gun.t>,
  lastServed: option<position>,
  currentTicket: option<position>,
  yourPosition: option<position>,
}
type action =
  | TakeANumber(int)
  | LastServedLoaded(option<position>)
  // | LastIssuedLoaded(option<position>)
  | QueueUpdated(option<GunDb.Gun.t>)

let reducer = (state, action) => {
  switch action {
  | LastServedLoaded(lastServed) => {...state, lastServed}
  // | LastIssuedLoaded(Some(lastIssued)) => {
  //     ...state,
  //     currentTicket: Some({...lastIssued, number: lastIssued.number + 1}),
  //   }
  // | LastIssuedLoaded(None) => {...state, currentTicket: None}
  | TakeANumber(number) => {
      ...state,
      currentTicket: Some({
        number: (
          state.currentTicket->Belt.Option.getWithDefault(GunDbMock.getStartPosition())
        ).number + 1,
        time: Js.Date.make()->Js.Date.toLocaleTimeString,
      }),
      yourPosition: Some({
        number,
        time: Js.Date.make()->Js.Date.toLocaleTimeString,
      }),
    }
  | QueueUpdated(queue) => {
      ...state,
      queue,
    }
  }
}

@react.component
let make = (~storeId) => {
  let (state, dispatch) = React.useReducer(
    reducer,
    {
      queue: None,
      lastServed: None,
      currentTicket: None,
      yourPosition: None,
    },
  )

  React.useEffect0(_ => {
    Js.log2("storeId", storeId)
    let queueRef = GunDbMock.getQueueByStoreId(~storeId)
    let _ = queueRef->GunDb.Gun.on(queue => {
      let _ = dispatch(QueueUpdated(queue))
    })

    // let _ = dispatch(LastServedLoaded(GunDbMock.getLastServed()))
    // let _ = dispatch(LastIssuedLoaded(queue->Belt.Array.get(queue->Belt.Array.length - 1)))
    None
  })

  let handleServeNext = _ => {
    GunDbMock.serveNext()
    dispatch(LastServedLoaded(GunDbMock.getLastServed()))
  }

  let handleTakeANumber = _ => {
    let newNumber = (
      state.currentTicket->Belt.Option.getWithDefault(GunDbMock.getStartPosition())
    ).number
    let _ = GunDbMock.enterQueue(~storeId, ~number=newNumber)
    dispatch(TakeANumber(newNumber))
  }

  <div className="App container">
    <div className="bg-blue-100 py-24 sm:py-32 w-96 m-auto">
      {switch state.currentTicket {
      | None => <TakeATicket text="1" />
      | Some(position) => <TakeATicket text={position.number->Belt.Int.toString} />
      }}
    </div>
    <div className="card w-96 bg-base-100 shadow-xl rounded p-4">
      {switch state.yourPosition {
      | None =>
        <>
          <p> {"You are not in the queue"->React.string} </p>
          <button className="rounded bg-green-400 p-5 m-4" onClick={handleTakeANumber}>
            {"Take a Number"->React.string}
          </button>
        </>
      | Some(position) =>
        <div>
          <p> {"Your Ticket Number is: "->React.string} </p>
          <p className="text-8xl bg-green-400 p-8"> {position.number->React.int} </p>
          <p> {position.time->React.string} </p>
        </div>
      }}
    </div>
    {switch state.lastServed {
    | Some(lastServed) =>
      <div className="card w-96 bg-base-100 shadow-xl rounded p-4">
        <div className="text-8xl bg-yellow-400 p-8"> {lastServed.number->React.int} </div>
        <div className="card-body">
          <h2 className="card-title font-bold">
            {"Last Served at: "->React.string}
            {lastServed.time->React.string}
          </h2>
          <p> {"Take a Number so that you can be served soon!"->React.string} </p>
          <button onClick={_ => handleServeNext()} className="btn btn-primary">
            {"Process Next"->React.string}
          </button>
        </div>
      </div>
    | None => React.null
    }}
    {switch state.queue {
    | None => React.null
    | Some(queue) => <RenderQueue storeId={storeId} />
    }}
  </div>
}
