@react.component
let make = (~storeId) => {
  let (state, setState) = React.useState(_ => Belt.Map.String.empty)

  open GunDb
  React.useEffect0(_ => {
    let _ =
      gun
      ->Gun.get("stores")
      ->Gun.get(storeId)
      ->Gun.get("queue")
      ->Gun.map()
      ->Gun.onceWithKey((item: Types.position, key: string) => {
        Js.log4("queue item", item.number, item.time, key)
        setState(state => state->Belt.Map.String.set(key, item))
      })
    None
  })
  /*
  <> {React.null} </>
 */
  <>
    <div> {"Queue"->React.string} </div>
    <table className="table-auto w-full">
      <thead>
        <tr>
          <th> {"Number"->React.string} </th>
          <th> {"Time"->React.string} </th>
        </tr>
      </thead>
      <tbody>
        {state
        ->Belt.Map.String.mapWithKey((key, item: Types.position) => {
          <tr className="grid-rows-2" key={key}>
            <td className="text-center"> {item.number->React.int} </td>
            <td className=""> {item.time->React.string} </td>
          </tr>
        })
        ->Belt.Map.String.valuesToArray
        ->React.array}
      </tbody>
    </table>
  </>
}
