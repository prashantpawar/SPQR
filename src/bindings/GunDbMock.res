open Types
let _queue = ref([
  {number: 1, time: "10:05AM"},
  {number: 2, time: "10:10AM"},
  {number: 3, time: "10:15AM"},
  {number: 4, time: "10:20AM"},
  {number: 5, time: "10:25AM"},
  {number: 6, time: "10:30AM"},
  {number: 7, time: "10:35AM"},
  {number: 8, time: "10:40AM"},
])
let _lastServed = ref(_queue.contents->Js.Array2.shift)
let _startPosition = {
  number: 1,
  time: Js.Date.make()->Js.Date.toLocaleTimeString,
}

let _enterQueue = num => {
  let _ =
    _queue.contents->Js.Array2.push({number: num, time: Js.Date.make()->Js.Date.toLocaleTimeString})
  _queue
}

let serveNext = () => {
  _lastServed := _queue.contents->Js.Array2.shift
}

let getQueueByStoreId = (~storeId) => {
  open GunDb
  gun->Gun.get("stores")->Gun.get(storeId)->Gun.get("queue")
}

let getLastServed = () => _lastServed.contents

let getStartPosition = () => _startPosition

let registerStore = async (~name, ~email) => {
  open GunDb
  let storeId = await sea->Sea.asyncWork(email)

  // Create a new store in GunDB
  let storeRef = gun->Gun.get("stores")->Gun.get(storeId)
  await storeRef->Gun.put({"name": name, "email": email})
  storeId
}

let enterQueue = async (~storeId, ~number) => {
  open GunDb
  let queueRef = gun->Gun.get("stores")->Gun.get(storeId)->Gun.get("queue")

  await queueRef->Gun.set({"number": number, "time": Js.Date.make()->Js.Date.toLocaleTimeString})

  queueRef
}
