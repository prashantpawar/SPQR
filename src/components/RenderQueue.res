@react.component
let make = (~queue: array<Types.position>) => {
  <>
    {queue->Belt.Array.mapWithIndex((i, item) => {
      <div className="queue-item" key={i->Belt.Int.toString}>
        <div className="queue-item__duration"> {item.number->React.int} </div>
      </div>
    })}
  </>
}
